import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/paymob_payment_repository.dart';
import '../models/paymob_payment.dart';
import 'paymob_payment_state.dart';

/// Coordinates backend-created Paymob checkouts and authoritative status
/// checks. It never marks a payment successful on its own: only
/// `orders.payment_status = paid` (written by the webhook RPC) does that.
class PaymobPaymentCubit extends Cubit<PaymobPaymentState> {
  PaymobPaymentCubit({PaymobPaymentRepository? repository})
    : _repository = repository ?? const PaymobPaymentRepository(),
      super(const PaymobPaymentState());

  static final PaymobPaymentCubit instance = PaymobPaymentCubit();

  final PaymobPaymentRepository _repository;
  bool _refreshing = false;

  Future<PaymentCheckout?> start(String orderId) async {
    if (state.phase == PaymobPaymentPhase.creating) {
      return state.checkout;
    }

    emit(const PaymobPaymentState(phase: PaymobPaymentPhase.creating));

    try {
      final checkout = await _repository.createCheckout(orderId);
      if (isClosed) return null;
      emit(
        PaymobPaymentState(
          phase: PaymobPaymentPhase.awaiting,
          checkout: checkout,
        ),
      );
      return checkout;
    } on PaymentException catch (error) {
      if (isClosed) return null;

      // The backend may have quarantined the attempt while we were calling it,
      // or a late webhook may have settled the order. Re-read the authoritative
      // state before showing a retry button.
      PaymentSnapshot? snapshot;
      if (_shouldReconcile(error.message)) {
        try {
          snapshot = await _repository.fetchStatus(orderId);
        } catch (_) {
          // Keep the safe backend message.
        }
        if (isClosed) return null;
        if (snapshot?.isPaid == true) {
          emit(
            PaymobPaymentState(
              phase: PaymobPaymentPhase.confirmed,
              snapshot: snapshot,
            ),
          );
          return null;
        }
      }

      emit(
        PaymobPaymentState(
          phase: PaymobPaymentPhase.error,
          snapshot: snapshot,
          message: error.message,
        ),
      );
      return null;
    } catch (_) {
      if (isClosed) return null;
      emit(
        const PaymobPaymentState(
          phase: PaymobPaymentPhase.error,
          message:
              'Could not start the card payment. Check your connection and try again.',
        ),
      );
      return null;
    }
  }

  Future<void> refresh(String orderId) async {
    if (_refreshing || state.phase == PaymobPaymentPhase.confirmed) return;
    _refreshing = true;
    try {
      final snapshot = await _repository.fetchStatus(orderId);
      if (isClosed) return;

      final phase = snapshot.isPaid
          ? PaymobPaymentPhase.confirmed
          : (snapshot.isFailed || snapshot.needsReview)
          ? PaymobPaymentPhase.failed
          : PaymobPaymentPhase.awaiting;

      emit(
        state.copyWith(phase: phase, snapshot: snapshot, clearMessage: true),
      );
    } on PaymentException catch (error) {
      if (isClosed || state.phase == PaymobPaymentPhase.confirmed) return;
      // Keep polling on a transient status error, but show it in the UI.
      emit(state.copyWith(message: error.message));
    } finally {
      _refreshing = false;
    }
  }

  void markLaunchFailed() {
    if (isClosed) return;
    emit(
      state.copyWith(
        message:
            'The Paymob payment page could not be opened. Tap "Reopen payment page" to try again.',
      ),
    );
  }

  void reset() {
    if (isClosed) return;
    emit(const PaymobPaymentState());
  }

  bool _shouldReconcile(String message) {
    final lower = message.toLowerCase();
    return lower.contains('not confirmed') ||
        lower.contains('outcome is unknown') ||
        lower.contains('could not confirm') ||
        lower.contains('already been paid');
  }
}
