import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../bouquet/cubit/bouquet_cubit.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../data/checkout_order_builder.dart';
import '../models/checkout_exception.dart';
import '../models/checkout_line_item.dart';
import '../utils/checkout_delivery.dart';
import 'checkout_state.dart';

export '../models/checkout_exception.dart';
export '../models/checkout_line_item.dart';

/// Shared order data collected across the checkout flow, and the single
/// place that writes an order into the same `orders` / `order_items` tables
/// the admin dashboard reads.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(const CheckoutState());

  static final CheckoutCubit instance = CheckoutCubit();

  static const int deliveryFee = 30;
  static const int serviceFee = 10;

  bool get hasMessage => state.hasMessage;

  String get messageText => state.messageText;

  String get fullName => state.fullName;

  String get phone => state.phone;

  String get whatsapp => state.whatsapp;

  String get location => state.location;

  String get notes => state.notes;

  CheckoutSource get source => state.source;

  String? get lastOrderCode => state.lastOrderCode;

  /// Next-day delivery slot; the same value is stored on the order row so
  /// the admin can display it.
  static DateTime get deliverySlot => CheckoutDelivery.slot;

  String get deliveryDate => CheckoutDelivery.date;

  String get deliveryTime => CheckoutDelivery.time;

  String get deliveryDateTimeText => CheckoutDelivery.dateTimeText;

  /// Subtotal of what is being checked out: the saved cart for cart
  /// checkout, the live bouquet builder for the direct flow.
  int get bouquetPrice => state.source == CheckoutSource.cart
      ? CartCubit.instance.totalPrice
      : BouquetCubit.instance.totalPrice;

  int get totalPrice => bouquetPrice + deliveryFee + serviceFee;

  String get bouquetDescription => BouquetCubit.instance.descriptionText;

  /// Items being purchased, in the shape the order summary displays.
  List<String> get checkoutLines =>
      CheckoutOrderBuilder.buildLines(state.source);

  /// Structured checkout lines (photo, name, composition, line price) so the
  /// order summary can draw one card per item instead of a single card.
  List<CheckoutLineItem> get checkoutItems =>
      CheckoutOrderBuilder.buildLineItems(state.source);

  void setMessage({required bool hasMessage, required String text}) {
    emit(state.copyWith(hasMessage: hasMessage, messageText: text.trim()));
  }

  void setDeliveryDetails({
    required String fullName,
    required String phone,
    required String whatsapp,
    required String location,
    required String notes,
  }) {
    emit(
      state.copyWith(
        fullName: fullName.trim(),
        phone: phone.trim(),
        whatsapp: whatsapp.trim(),
        location: location.trim(),
        notes: notes.trim(),
      ),
    );
  }

  /// Marks which items the payment screen should turn into an order.
  /// Called before navigating to the payment screen.
  void beginCheckout(CheckoutSource source) {
    emit(state.copyWith(source: source));
  }

  void setPaymentMethod(String method) {
    emit(state.copyWith(paymentMethod: method));
  }

  /// Inserts the order and its items into Supabase, then clears the draft
  /// (bouquet selection and, for cart checkout, the cart).
  ///
  /// Throws [CheckoutException] with a user-readable message on failure.
  Future<void> submitOrder() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw CheckoutException('Please sign in to place an order');
    }

    final items = buildItems();
    if (items.isEmpty) {
      throw CheckoutException(
        state.source == CheckoutSource.cart
            ? 'Your cart is empty'
            : 'Your bouquet is empty',
      );
    }

    final subtotal = items.fold<int>(
      0,
      (sum, item) =>
          sum +
          ((item['price_snapshot'] as num) * (item['quantity'] as num)).round(),
    );
    final total = subtotal + deliveryFee + serviceFee;
    final now = DateTime.now().toUtc();
    final slot = deliverySlot.toUtc();
    final code = CheckoutOrderBuilder.generateOrderCode();
    final source = state.source;

    String? orderId;
    try {
      final orderRow = await client
          .from('orders')
          .insert({
            'order_code': code,
            'status': 'PENDING',
            'user_id': user.id,
            'message': state.hasMessage && state.messageText.isNotEmpty
                ? state.messageText
                : null,
            'additional_notes': state.notes.isEmpty ? null : state.notes,
            'delivery_address': state.location,
            'delivery_date': slot.toIso8601String(),
            'order_time': slot.toIso8601String(),
            'delivery_fee': deliveryFee,
            'service_fee': serviceFee,
            'total': total,
            'payment_method': state.paymentMethod,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select('id')
          .single();
      orderId = orderRow['id'] as String?;

      await client.from('order_items').insert([
        for (final item in items) {...item, 'order_id': orderId},
      ]);
    } catch (error) {
      // A half-written order (row created, items failed) must not linger in
      // the admin dashboard, so remove it before reporting the failure.
      if (orderId != null) {
        try {
          await client.from('orders').delete().eq('id', orderId);
        } catch (_) {
          // Cleanup is best-effort; the checkout error below is what matters.
        }
      }
      throw CheckoutException(
        'Could not place your order. Check your connection and try again. '
        '($error)',
      );
    }

    _resetDraft(lastOrderCode: code, clearCart: source == CheckoutSource.cart);
  }

  /// Builds the `order_items` rows for the current draft. Exposed for tests;
  /// production code goes through [submitOrder].
  @visibleForTesting
  List<Map<String, dynamic>> buildItems() =>
      CheckoutOrderBuilder.buildOrderItems(state.source);

  void _resetDraft({required String lastOrderCode, required bool clearCart}) {
    BouquetCubit.instance.clear();
    if (clearCart) {
      CartCubit.instance.clearCart();
    }
    emit(CheckoutState(lastOrderCode: lastOrderCode));
  }
}
