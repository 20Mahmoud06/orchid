import 'dart:async';

import 'package:ORCHID/features/payment/cubit/paymob_payment_cubit.dart';
import 'package:ORCHID/features/payment/cubit/paymob_payment_state.dart';
import 'package:ORCHID/features/payment/data/paymob_payment_repository.dart';
import 'package:ORCHID/features/payment/models/paymob_payment.dart';
import 'package:flutter_test/flutter_test.dart';

PaymentCheckout _checkout({bool reused = false}) {
  return PaymentCheckout(
    attemptId: 'attempt-1',
    orderId: 'order-1',
    checkoutUrl: 'https://accept.paymob.com/unifiedcheckout/?publicKey=pk',
    amountCents: 12500,
    currency: 'EGP',
    reused: reused,
  );
}

PaymentSnapshot _snapshot({
  String orderStatus = 'PENDING',
  String orderPaymentStatus = 'unpaid',
  String? attemptStatus,
}) {
  return PaymentSnapshot(
    orderStatus: orderStatus,
    orderPaymentStatus: orderPaymentStatus,
    latestAttemptStatus: attemptStatus,
    amountCents: 12500,
    currency: 'EGP',
  );
}

class _FakeRepository extends PaymobPaymentRepository {
  _FakeRepository();

  int createCalls = 0;
  int statusCalls = 0;
  Future<PaymentCheckout> Function(String orderId)? onCreate;
  Future<PaymentSnapshot> Function(String orderId)? onStatus;

  @override
  Future<PaymentCheckout> createCheckout(String orderId) {
    createCalls += 1;
    return onCreate?.call(orderId) ??
        Future<PaymentCheckout>.value(_checkout());
  }

  @override
  Future<PaymentSnapshot> fetchStatus(String orderId) {
    statusCalls += 1;
    return onStatus?.call(orderId) ??
        Future<PaymentSnapshot>.value(_snapshot());
  }
}

void main() {
  group('PaymentCheckout', () {
    test('parses the minimal checkout response', () {
      final checkout = PaymentCheckout.fromJson({
        'attempt_id': 'attempt-1',
        'order_id': 'order-1',
        'checkout_url': 'https://accept.paymob.com/unifiedcheckout/?x=1',
        'amount_cents': 12500,
        'currency': 'EGP',
        'reused': true,
      });

      expect(checkout.attemptId, 'attempt-1');
      expect(checkout.orderId, 'order-1');
      expect(checkout.checkoutUrl, contains('accept.paymob.com'));
      expect(checkout.amountCents, 12500);
      expect(checkout.currency, 'EGP');
      expect(checkout.reused, isTrue);
    });

    test('rejects an incomplete checkout response', () {
      expect(
        () => PaymentCheckout.fromJson({
          'attempt_id': 'attempt-1',
          'order_id': 'order-1',
          'amount_cents': 12500,
        }),
        throwsA(isA<PaymentException>()),
      );
    });
  });

  group('PaymentSnapshot', () {
    test('reports a paid order', () {
      final snapshot = _snapshot(
        orderPaymentStatus: 'paid',
        attemptStatus: 'succeeded',
      );

      expect(snapshot.isPaid, isTrue);
      expect(snapshot.isFailed, isFalse);
      expect(snapshot.needsReview, isFalse);
    });

    test('treats pending Paymob attempts as pending', () {
      expect(_snapshot(attemptStatus: 'created').isPending, isTrue);
      expect(_snapshot(attemptStatus: 'pending').isPending, isTrue);
    });

    test('treats failed Paymob attempts as failed', () {
      for (final status in ['failed', 'expired', 'cancelled']) {
        expect(
          _snapshot(attemptStatus: status).isFailed,
          isTrue,
          reason: status,
        );
      }
    });

    test('treats a canceled order as failed', () {
      expect(_snapshot(orderStatus: 'CANCELED').isFailed, isTrue);
    });

    test('flags disputes and refund-pending orders for review', () {
      expect(_snapshot(attemptStatus: 'disputed').needsReview, isTrue);
      expect(
        _snapshot(orderPaymentStatus: 'refund_pending').needsReview,
        isTrue,
      );
    });

    test('reports an unknown state when no attempt exists', () {
      expect(_snapshot().isUnknown, isTrue);
    });

    test('quarantines an uncertain Paymob attempt', () {
      final snapshot = _snapshot(
        orderPaymentStatus: 'pending',
        attemptStatus: 'unknown',
      );

      expect(snapshot.isQuarantined, isTrue);
      expect(snapshot.isPending, isFalse);
      expect(snapshot.isFailed, isFalse);
      expect(snapshot.isPaid, isFalse);
    });

    test('reads the latest attempt from the joined rows', () {
      final snapshot = PaymentSnapshot.fromRows(
        order: {'status': 'PENDING', 'payment_status': 'pending', 'total': 125},
        attempts: [
          {'status': 'pending', 'amount_cents': 12500, 'currency': 'EGP'},
        ],
      );

      expect(snapshot.latestAttemptStatus, 'pending');
      expect(snapshot.amountCents, 12500);
      expect(snapshot.isPending, isTrue);
    });
  });

  group('PaymobPaymentCubit', () {
    late _FakeRepository repository;
    late PaymobPaymentCubit cubit;

    setUp(() {
      repository = _FakeRepository();
      cubit = PaymobPaymentCubit(repository: repository);
    });

    tearDown(() => cubit.close());

    test('start emits awaiting with the backend checkout', () async {
      final checkout = await cubit.start('order-1');

      expect(checkout, isNotNull);
      expect(cubit.state.phase, PaymobPaymentPhase.awaiting);
      expect(cubit.state.checkout?.attemptId, 'attempt-1');
      expect(repository.createCalls, 1);
    });

    test('start surfaces a readable backend error', () async {
      repository.onCreate = (_) =>
          Future<PaymentCheckout>.error(const PaymentException('No card.'));

      final checkout = await cubit.start('order-1');

      expect(checkout, isNull);
      expect(cubit.state.phase, PaymobPaymentPhase.error);
      expect(cubit.state.message, 'No card.');
      expect(repository.statusCalls, 0);
    });

    test('start reconciles an uncertain backend outcome', () async {
      repository.onCreate = (_) => Future<PaymentCheckout>.error(
        const PaymentException(
          'Paymob has not confirmed your previous payment yet.',
        ),
      );
      repository.onStatus = (_) => Future<PaymentSnapshot>.value(
        _snapshot(orderPaymentStatus: 'pending', attemptStatus: 'unknown'),
      );

      final checkout = await cubit.start('order-1');

      expect(checkout, isNull);
      expect(cubit.state.phase, PaymobPaymentPhase.error);
      expect(cubit.state.snapshot?.isQuarantined, isTrue);
      expect(repository.statusCalls, 1);
    });

    test('start upgrades to confirmed when the order is already paid', () async {
      repository.onCreate = (_) => Future<PaymentCheckout>.error(
        const PaymentException('This order has already been paid.'),
      );
      repository.onStatus = (_) => Future<PaymentSnapshot>.value(
        _snapshot(orderPaymentStatus: 'paid', attemptStatus: 'succeeded'),
      );

      final checkout = await cubit.start('order-1');

      expect(checkout, isNull);
      expect(cubit.state.phase, PaymobPaymentPhase.confirmed);
      expect(repository.statusCalls, 1);
    });

    test('start upgrades to confirmed when reconciliation finds payment', () async {
      repository.onCreate = (_) => Future<PaymentCheckout>.error(
        const PaymentException('Could not confirm the Paymob response.'),
      );
      repository.onStatus = (_) => Future<PaymentSnapshot>.value(
        _snapshot(orderPaymentStatus: 'paid', attemptStatus: 'succeeded'),
      );

      final checkout = await cubit.start('order-1');

      expect(checkout, isNull);
      expect(cubit.state.phase, PaymobPaymentPhase.confirmed);
      expect(repository.statusCalls, 1);
    });

    test(
      'a second start while creating does not call the backend twice',
      () async {
        final completer = Completer<PaymentCheckout>();
        repository.onCreate = (_) => completer.future;

        final first = cubit.start('order-1');
        final second = await cubit.start('order-1');

        expect(second, isNull);
        expect(repository.createCalls, 1);
        expect(cubit.state.phase, PaymobPaymentPhase.creating);

        completer.complete(_checkout());
        expect(await first, isNotNull);
        expect(cubit.state.phase, PaymobPaymentPhase.awaiting);
      },
    );

    test('refresh confirms only from the backend paid state', () async {
      repository.onStatus = (_) => Future<PaymentSnapshot>.value(
        _snapshot(orderPaymentStatus: 'paid', attemptStatus: 'succeeded'),
      );

      await cubit.refresh('order-1');

      expect(cubit.state.phase, PaymobPaymentPhase.confirmed);
      expect(cubit.state.isConfirmed, isTrue);
      expect(repository.statusCalls, 1);
    });

    test('refresh reports failed attempts without confirming', () async {
      repository.onStatus = (_) =>
          Future<PaymentSnapshot>.value(_snapshot(attemptStatus: 'failed'));

      await cubit.refresh('order-1');

      expect(cubit.state.phase, PaymobPaymentPhase.failed);
      expect(cubit.state.isConfirmed, isFalse);
    });

    test(
      'refresh keeps a transient error visible while staying awaiting',
      () async {
        await cubit.start('order-1');
        repository.onStatus = (_) => Future<PaymentSnapshot>.error(
          const PaymentException('Network is offline.'),
        );

        await cubit.refresh('order-1');

        expect(cubit.state.phase, PaymobPaymentPhase.awaiting);
        expect(cubit.state.message, 'Network is offline.');
      },
    );

    test('refresh never regresses a confirmed payment', () async {
      repository.onStatus = (_) => Future<PaymentSnapshot>.value(
        _snapshot(orderPaymentStatus: 'paid', attemptStatus: 'succeeded'),
      );
      await cubit.refresh('order-1');

      repository.onStatus = (_) =>
          Future<PaymentSnapshot>.value(_snapshot(attemptStatus: 'failed'));
      await cubit.refresh('order-1');

      expect(cubit.state.phase, PaymobPaymentPhase.confirmed);
      expect(repository.statusCalls, 1);
    });

    test(
      'markLaunchFailed keeps the checkout available for reopening',
      () async {
        await cubit.start('order-1');

        cubit.markLaunchFailed();

        expect(cubit.state.checkout, isNotNull);
        expect(cubit.state.message, contains('Reopen payment page'));
      },
    );
  });
}
