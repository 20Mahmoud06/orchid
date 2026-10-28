import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/paymob_payment.dart';

/// Talks to the Paymob Edge Function and reads the authoritative payment state
/// that the webhook writes.
class PaymobPaymentRepository {
  const PaymobPaymentRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<PaymentCheckout> createCheckout(String orderId) async {
    try {
      final response = await _supabase.functions.invoke(
        'paymob-create-intention',
        body: {'order_id': orderId},
      );
      final data = response.data;
      if (data is! Map) {
        throw const PaymentException(
          'The payment service returned an invalid response.',
        );
      }
      final json = <String, dynamic>{};
      data.forEach((key, value) => json[key.toString()] = value);
      final checkout = PaymentCheckout.fromJson(json);
      final uri = Uri.tryParse(checkout.checkoutUrl);
      if (uri == null || uri.scheme != 'https') {
        throw const PaymentException(
          'The payment service returned an unsafe checkout URL.',
        );
      }
      return checkout;
    } on FunctionException catch (error) {
      throw PaymentException(_functionMessage(error));
    } on PaymentException {
      rethrow;
    } catch (_) {
      throw const PaymentException(
        'Could not start the card payment. Check your connection and try again.',
      );
    }
  }

  Future<PaymentSnapshot> fetchStatus(String orderId) async {
    try {
      final order = await _supabase
          .from('orders')
          .select('id, order_code, status, payment_status, total')
          .eq('id', orderId)
          .maybeSingle();
      if (order == null) {
        throw const PaymentException('This order is no longer available.');
      }

      final rows = await _supabase
          .from('payment_attempts')
          .select('status, amount_cents, currency, created_at')
          .eq('order_id', orderId)
          .order('created_at', ascending: false)
          .limit(5);

      final attempts = <Map<String, dynamic>>[
        for (final row in rows) Map<String, dynamic>.from(row),
      ];

      return PaymentSnapshot.fromRows(order: order, attempts: attempts);
    } on PaymentException {
      rethrow;
    } on PostgrestException catch (error) {
      throw PaymentException(
        error.code == '42501' || error.code == 'PGRST116'
            ? 'You do not have access to this payment.'
            : 'Could not check the payment status. Please try again.',
      );
    } catch (_) {
      throw const PaymentException(
        'Could not check the payment status. Check your connection and try again.',
      );
    }
  }

  String _functionMessage(FunctionException error) {
    final details = error.details;
    if (details is Map) {
      final message = details['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (error.status == 401) {
      return 'Please sign in again to pay by card.';
    }
    if (error.status == 409) {
      return 'A payment is already in progress for this order.';
    }
    if (error.status == 503) {
      return 'Card payments are not configured yet.';
    }
    return 'Could not start the card payment. Please try again.';
  }
}
