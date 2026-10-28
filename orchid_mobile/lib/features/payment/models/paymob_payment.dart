/// Minimal, client-safe Paymob payment data.
///
/// The checkout URL includes Paymob's public key and a short-lived client
/// secret. The secret key, API key, and HMAC secret never reach the app.
class PaymentCheckout {
  const PaymentCheckout({
    required this.attemptId,
    required this.orderId,
    required this.checkoutUrl,
    required this.amountCents,
    required this.currency,
    required this.reused,
  });

  final String attemptId;
  final String orderId;
  final String checkoutUrl;
  final int amountCents;
  final String currency;
  final bool reused;

  factory PaymentCheckout.fromJson(Map<String, dynamic> json) {
    final attemptId = json['attempt_id'] as String? ?? '';
    final orderId = json['order_id'] as String? ?? '';
    final checkoutUrl = json['checkout_url'] as String? ?? '';
    final amountCents = (json['amount_cents'] as num?)?.round() ?? 0;
    if (attemptId.isEmpty || orderId.isEmpty || checkoutUrl.isEmpty) {
      throw const PaymentException(
        'The payment service returned an incomplete checkout.',
      );
    }
    return PaymentCheckout(
      attemptId: attemptId,
      orderId: orderId,
      checkoutUrl: checkoutUrl,
      amountCents: amountCents,
      currency: json['currency'] as String? ?? 'EGP',
      reused: json['reused'] == true,
    );
  }
}

/// Authoritative payment state read from `orders` + `payment_attempts`.
///
/// Only the webhook writes these values. The app never trusts redirect query
/// parameters or the browser's success page.
class PaymentSnapshot {
  const PaymentSnapshot({
    required this.orderStatus,
    required this.orderPaymentStatus,
    required this.latestAttemptStatus,
    this.amountCents,
    this.currency,
  });

  final String orderStatus;
  final String orderPaymentStatus;
  final String? latestAttemptStatus;
  final int? amountCents;
  final String? currency;

  bool get isPaid => orderPaymentStatus == 'paid';

  bool get needsReview =>
      latestAttemptStatus == 'disputed' ||
      orderPaymentStatus == 'refund_pending';

  /// Paymob may have accepted the last request, but no verified outcome exists.
  /// The backend blocks a new chargeable intention until this is reconciled.
  bool get isQuarantined =>
      !isPaid && !needsReview && latestAttemptStatus == 'unknown';

  bool get isFailed =>
      !isPaid &&
      !needsReview &&
      !isQuarantined &&
      (orderStatus == 'CANCELED' ||
          orderPaymentStatus == 'failed' ||
          latestAttemptStatus == 'failed' ||
          latestAttemptStatus == 'expired' ||
          latestAttemptStatus == 'cancelled');

  bool get isPending =>
      !isPaid &&
      !isFailed &&
      !needsReview &&
      !isQuarantined &&
      (latestAttemptStatus == 'created' ||
          latestAttemptStatus == 'pending' ||
          orderPaymentStatus == 'pending');

  /// No payment attempt exists at all yet.
  bool get isUnknown =>
      !isPaid &&
      !isFailed &&
      !needsReview &&
      !isQuarantined &&
      latestAttemptStatus == null;

  factory PaymentSnapshot.fromRows({
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> attempts,
  }) {
    final latest = attempts.isEmpty ? null : attempts.first;
    return PaymentSnapshot(
      orderStatus: order['status'] as String? ?? '',
      orderPaymentStatus: order['payment_status'] as String? ?? 'unpaid',
      latestAttemptStatus: latest?['status'] as String?,
      amountCents: (latest?['amount_cents'] as num?)?.round(),
      currency: latest?['currency'] as String?,
    );
  }
}

class PaymentException implements Exception {
  const PaymentException(this.message);

  final String message;

  @override
  String toString() => message;
}
