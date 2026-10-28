/// An order placed by this customer, as stored in the `orders` and
/// `order_items` tables (the same rows the admin dashboard manages).
class CustomerOrderItem {
  const CustomerOrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
    this.description,
    this.message,
  });

  final String name;
  final int quantity;
  final int unitPrice;
  final String? imageUrl;

  /// Human readable composition of a custom bouquet, taken from
  /// `custom_components.description` when present.
  final String? description;

  /// Optional note the customer attached to this single cart line, taken from
  /// `custom_components.message` (same shape the admin dashboard reads).
  final String? message;

  int get total => unitPrice * quantity;

  factory CustomerOrderItem.fromRow(Map<String, dynamic> row) {
    final components = row['custom_components'];
    String? description;
    String? message;
    if (components is Map) {
      if (components['description'] is String) {
        description = components['description'] as String;
      }
      if (components['message'] is String) {
        message = components['message'] as String;
      }
    }
    return CustomerOrderItem(
      name: row['name_snapshot'] as String? ?? 'Item',
      quantity: (row['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: ((row['price_snapshot'] as num?) ?? 0).round(),
      imageUrl: row['image_snapshot'] as String?,
      description: description,
      message: (message == null || message.trim().isEmpty) ? null : message,
    );
  }
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.items,
    this.deliveryAddress = '',
    this.message,
    this.notes,
    this.paymentMethod = '',
    this.paymentStatus = '',
  });

  final String id;

  /// Stored without the `#` prefix (same as the admin dashboard).
  final String orderCode;

  /// Raw DB status: PENDING / PREPARING / COMPLETED / CANCELED.
  final String status;
  final DateTime createdAt;
  final int total;
  final List<CustomerOrderItem> items;
  final String deliveryAddress;
  final String? message;
  final String? notes;

  /// `orders.payment_method`: cash / card.
  final String paymentMethod;

  /// Server-written `orders.payment_status`: unpaid / pending / paid / failed /
  /// refund_pending / refunded.
  final String paymentStatus;

  String get displayCode => '#$orderCode';

  /// A card order that is still active but has no confirmed payment can safely
  /// go back through the backend. The backend reuses an open Paymob session or
  /// refuses with a clear message when an outcome is quarantined.
  bool get canResumePayment =>
      status == 'PENDING' &&
      paymentMethod == 'card' &&
      (paymentStatus == 'unpaid' ||
          paymentStatus == 'pending' ||
          paymentStatus == 'failed');

  String get title {
    if (items.isEmpty) return 'order';
    if (items.length == 1) return items.first.name;
    final more = items.length - 1;
    return '${items.first.name} +$more more';
  }

  String? get coverImageUrl {
    for (final item in items) {
      final url = item.imageUrl;
      if (url != null && url.startsWith('http')) return url;
    }
    return null;
  }

  CustomerOrder copyWith({String? status, String? paymentStatus}) {
    return CustomerOrder(
      id: id,
      orderCode: orderCode,
      status: status ?? this.status,
      createdAt: createdAt,
      total: total,
      items: items,
      deliveryAddress: deliveryAddress,
      message: message,
      notes: notes,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  factory CustomerOrder.fromRow(
    Map<String, dynamic> row, {
    List<CustomerOrderItem> items = const <CustomerOrderItem>[],
  }) {
    return CustomerOrder(
      id: row['id'] as String? ?? '',
      orderCode: row['order_code'] as String? ?? '',
      status: row['status'] as String? ?? 'PENDING',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      total: ((row['total'] as num?) ?? 0).round(),
      deliveryAddress: row['delivery_address'] as String? ?? '',
      message: row['message'] as String?,
      notes: row['additional_notes'] as String?,
      paymentMethod: row['payment_method'] as String? ?? '',
      paymentStatus: row['payment_status'] as String? ?? '',
      items: items,
    );
  }
}
