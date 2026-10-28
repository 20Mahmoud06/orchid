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

  String? get lastOrderId => state.lastOrderId;

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
  Future<PlacedOrder> submitOrder() async {
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

    final slot = deliverySlot.toUtc();
    final source = state.source;

    try {
      // The database reprices every line from the trusted product table,
      // validates custom-bouquet components, generates the order code and
      // returns the authoritative total. The client cannot choose any of them.
      final raw = await client.rpc(
        'create_order',
        params: {
          'p_message': state.hasMessage && state.messageText.isNotEmpty
              ? state.messageText
              : null,
          'p_notes': state.notes.isEmpty ? null : state.notes,
          'p_delivery_address': state.location,
          'p_delivery_date': slot.toIso8601String(),
          'p_order_time': slot.toIso8601String(),
          'p_payment_method': state.paymentMethod,
          'p_items': items,
        },
      );

      if (raw is! Map) {
        throw CheckoutException(
          'Could not place your order. Please try again.',
        );
      }

      final data = Map<String, dynamic>.from(raw);
      final orderId = data['order_id'] as String?;
      final code = data['order_code'] as String?;
      final total = ((data['total'] as num?) ?? 0).round();
      if (orderId == null ||
          orderId.isEmpty ||
          code == null ||
          code.isEmpty ||
          total <= 0) {
        throw CheckoutException(
          'Could not place your order. Please try again.',
        );
      }

      final placed = PlacedOrder(
        id: orderId,
        code: code,
        total: total,
        paymentMethod: state.paymentMethod,
      );
      _resetDraft(
        lastOrderId: orderId,
        lastOrderCode: code,
        clearCart: source == CheckoutSource.cart,
      );
      return placed;
    } on CheckoutException {
      rethrow;
    } on PostgrestException catch (error) {
      throw CheckoutException(_checkoutMessage(error.message));
    } catch (_) {
      throw CheckoutException(
        'Could not place your order. Check your connection and try again.',
      );
    }
  }

  String _checkoutMessage(String rawMessage) {
    final message = rawMessage.toLowerCase();
    if (message.contains('price changed')) {
      return 'Prices changed while you were shopping. Please review your '
          'cart and place the order again.';
    }
    if (message.contains('no longer available')) {
      return 'One of the items is no longer available. Please review your '
          'cart and try again.';
    }
    if (message.contains('custom bouquet')) {
      return 'Your custom bouquet could not be validated. Please rebuild it '
          'and try again.';
    }
    if (message.contains('delivery')) {
      return 'Please check your delivery details and try again.';
    }
    if (message.contains('authentication') || message.contains('jwt')) {
      return 'Please sign in to place an order';
    }
    return 'Could not place your order. Check your connection and try again.';
  }

  /// Builds the `order_items` rows for the current draft. Exposed for tests;
  /// production code goes through [submitOrder].
  @visibleForTesting
  List<Map<String, dynamic>> buildItems() =>
      CheckoutOrderBuilder.buildOrderItems(state.source);

  void _resetDraft({
    required String lastOrderId,
    required String lastOrderCode,
    required bool clearCart,
  }) {
    BouquetCubit.instance.clear();
    if (clearCart) {
      CartCubit.instance.clearCart();
    }
    emit(CheckoutState(lastOrderId: lastOrderId, lastOrderCode: lastOrderCode));
  }
}

/// A just-created order, returned so card checkout can create its Paymob
/// attempt without rebuilding the draft (which is cleared after insertion).
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.code,
    required this.total,
    required this.paymentMethod,
  });

  final String id;
  final String code;
  final int total;
  final String paymentMethod;
}
