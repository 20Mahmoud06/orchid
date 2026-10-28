import 'package:equatable/equatable.dart';

import '../models/paymob_payment.dart';

enum PaymobPaymentPhase { idle, creating, awaiting, confirmed, failed, error }

class PaymobPaymentState extends Equatable {
  const PaymobPaymentState({
    this.phase = PaymobPaymentPhase.idle,
    this.checkout,
    this.snapshot,
    this.message,
  });

  final PaymobPaymentPhase phase;
  final PaymentCheckout? checkout;
  final PaymentSnapshot? snapshot;
  final String? message;

  bool get isBusy => phase == PaymobPaymentPhase.creating;

  bool get isConfirmed => phase == PaymobPaymentPhase.confirmed;

  bool get isFailed => phase == PaymobPaymentPhase.failed;

  bool get isError => phase == PaymobPaymentPhase.error;

  PaymobPaymentState copyWith({
    PaymobPaymentPhase? phase,
    PaymentCheckout? checkout,
    PaymentSnapshot? snapshot,
    String? message,
    bool clearCheckout = false,
    bool clearSnapshot = false,
    bool clearMessage = false,
  }) {
    return PaymobPaymentState(
      phase: phase ?? this.phase,
      checkout: clearCheckout ? null : (checkout ?? this.checkout),
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [phase, checkout, snapshot, message];
}
