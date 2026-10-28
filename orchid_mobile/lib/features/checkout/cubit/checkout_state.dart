import 'package:equatable/equatable.dart';

/// Which checkout path the customer took to reach the payment screen.
enum CheckoutSource { bouquet, cart }

/// Draft data collected across the checkout flow.
class CheckoutState extends Equatable {
  const CheckoutState({
    this.hasMessage = false,
    this.messageText = '',
    this.fullName = '',
    this.phone = '',
    this.whatsapp = '',
    this.location = '',
    this.notes = '',
    this.source = CheckoutSource.bouquet,
    this.paymentMethod = 'cash',
    this.lastOrderCode,
    this.lastOrderId,
  });

  final bool hasMessage;
  final String messageText;
  final String fullName;
  final String phone;
  final String whatsapp;
  final String location;
  final String notes;
  final CheckoutSource source;
  final String paymentMethod;

  /// The order code of the most recently submitted order, without the `#`
  /// prefix. Kept so the confirm screen can show the real code.
  final String? lastOrderCode;

  /// The database id of the most recently submitted order. Card payments use
  /// it to create/reuse the Paymob attempt without creating a duplicate order.
  final String? lastOrderId;

  CheckoutState copyWith({
    bool? hasMessage,
    String? messageText,
    String? fullName,
    String? phone,
    String? whatsapp,
    String? location,
    String? notes,
    CheckoutSource? source,
    String? paymentMethod,
    String? lastOrderCode,
    String? lastOrderId,
  }) {
    return CheckoutState(
      hasMessage: hasMessage ?? this.hasMessage,
      messageText: messageText ?? this.messageText,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      lastOrderCode: lastOrderCode ?? this.lastOrderCode,
      lastOrderId: lastOrderId ?? this.lastOrderId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        hasMessage,
        messageText,
        fullName,
        phone,
        whatsapp,
        location,
        notes,
        source,
        paymentMethod,
        lastOrderCode,
        lastOrderId,
      ];
}
