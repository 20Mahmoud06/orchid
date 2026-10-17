import '../../../../core/time/egypt_time.dart';

enum OrderStatus {
  pending('New'),
  preparing('Preparing'),
  completed('Completed'),
  canceled('Cancelled');

  const OrderStatus(this.label);

  final String label;

  String get dbValue => switch (this) {
        OrderStatus.pending => 'PENDING',
        OrderStatus.preparing => 'PREPARING',
        OrderStatus.completed => 'COMPLETED',
        OrderStatus.canceled => 'CANCELED',
      };

  static OrderStatus fromDb(String? value) => switch (value) {
        'PENDING' => OrderStatus.pending,
        'COMPLETED' => OrderStatus.completed,
        'CANCELED' => OrderStatus.canceled,
        _ => OrderStatus.preparing,
      };
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
    this.productId,
    this.customComponents,
  });

  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? imageUrl;
  final String? productId;
  final Map<String, dynamic>? customComponents;

  double get total => unitPrice * quantity;

  factory OrderItem.fromRow(Map<String, dynamic> row) => OrderItem(
        id: row['id'] as String? ?? '',
        productId: row['product_id'] as String?,
        name: row['name_snapshot'] as String? ?? 'Item',
        imageUrl: row['image_snapshot'] as String?,
        unitPrice: (row['price_snapshot'] as num?)?.toDouble() ?? 0,
        quantity: (row['quantity'] as num?)?.toInt() ?? 1,
        customComponents: row['custom_components'] is Map
            ? Map<String, dynamic>.from(row['custom_components'] as Map)
            : null,
      );
}

class Order {
  const Order({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.deliveryDate,
    required this.orderTime,
    required this.deliveryAddress,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.paymentMethod,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.message,
    this.additionalNotes,
    this.customerName,
    this.customerPhone,
  });

  final String id;
  final String orderCode;
  final OrderStatus status;
  final DateTime deliveryDate;
  final DateTime orderTime;
  final String deliveryAddress;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final String paymentMethod;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final String? message;
  final String? additionalNotes;
  final String? customerName;
  final String? customerPhone;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromRow(
    Map<String, dynamic> row, {
    List<OrderItem> items = const <OrderItem>[],
    String? customerName,
    String? customerPhone,
  }) {
    return Order(
      id: row['id'] as String? ?? '',
      orderCode: row['order_code'] as String? ?? '',
      status: OrderStatus.fromDb(row['status'] as String?),
      deliveryDate:
          DateTime.tryParse(row['delivery_date'] as String? ?? '') ??
              DateTime.now(),
      orderTime: DateTime.tryParse(row['order_time'] as String? ?? '') ??
          DateTime.now(),
      deliveryAddress: row['delivery_address'] as String? ?? '',
      deliveryFee: (row['delivery_fee'] as num?)?.toDouble() ?? 0,
      serviceFee: (row['service_fee'] as num?)?.toDouble() ?? 0,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: row['payment_method'] as String? ?? '',
      userId: row['user_id'] as String? ?? '',
      message: row['message'] as String?,
      additionalNotes: row['additional_notes'] as String?,
      createdAt: toEgyptTime(DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now()),
      updatedAt: toEgyptTime(DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now()),
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }
}
