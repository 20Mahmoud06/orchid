import 'dart:async';
import 'package:ORCHID/features/payment/view/widgets/payment_pending/payment_pending_actions.dart';
import 'package:ORCHID/features/payment/view/widgets/payment_pending/payment_pending_args.dart';
import 'package:ORCHID/features/payment/view/widgets/payment_pending/pending_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../order/cubit/orders_cubit.dart';
import '../../cubit/paymob_payment_cubit.dart';
import '../../cubit/paymob_payment_state.dart';
import '../../data/paymob_checkout_launcher.dart';

/// Web card-payment status page. It polls the backend and never trusts the
/// Paymob browser redirect. Wide screens use a two-column-style centered card;
/// narrow screens keep the Orchid mobile presentation.
class PaymentPendingScreen extends StatefulWidget {
  const PaymentPendingScreen({super.key, required this.args});

  final PaymentPendingArgs args;

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends State<PaymentPendingScreen>
    with WidgetsBindingObserver {
  final PaymobPaymentCubit _cubit = PaymobPaymentCubit.instance;

  Timer? _pollTimer;
  DateTime? _pollDeadline;
  bool _checking = false;
  bool _starting = false;
  bool _navigated = false;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A previous order's checkout must never leak into this one.
    PaymobPaymentCubit.instance.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Fires when the customer returns to the Orchid tab/window.
    if (state == AppLifecycleState.resumed) {
      _checkNow();
    }
  }

  /// Checks the server before starting anything. This covers a page reload,
  /// browser return and the Resume Payment action in order history: an
  /// already-paid order goes to confirmation, and a quarantined Paymob outcome
  /// never opens a second chargeable checkout.
  Future<void> _bootstrap() async {
    if (_starting || _navigated) return;
    setState(() {
      _starting = true;
      _timedOut = false;
    });

    await _cubit.refresh(widget.args.orderId);
    if (!mounted || _navigated) return;

    final snapshot = _cubit.state.snapshot;
    setState(() => _starting = false);
    if (snapshot != null &&
        (snapshot.isPaid ||
            snapshot.needsReview ||
            snapshot.isQuarantined ||
            snapshot.orderStatus == 'CANCELED')) {
      if (snapshot.isQuarantined || snapshot.needsReview) {
        _beginPolling();
      } else {
        _stopPolling();
      }
      return;
    }

    await _start();
  }

  Future<void> _start() async {
    if (_starting || _navigated) return;
    setState(() {
      _starting = true;
      _timedOut = false;
    });

    final checkout = await _cubit.start(widget.args.orderId);
    if (!mounted) return;
    setState(() => _starting = false);
    if (checkout == null) return;

    await _launch(checkout.checkoutUrl);
    if (!mounted) return;
    _beginPolling();
  }

  Future<void> _launch(String checkoutUrl) async {
    final opened = await launchPaymobCheckout(checkoutUrl);
    if (!mounted) return;
    if (!opened) {
      _cubit.markLaunchFailed();
    }
  }

  Future<void> _reopen() async {
    final checkout = _cubit.state.checkout;
    if (checkout == null) {
      await _start();
      return;
    }
    await _launch(checkout.checkoutUrl);
  }

  void _beginPolling() {
    _pollTimer?.cancel();
    _pollDeadline = DateTime.now().add(const Duration(minutes: 5));
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkNow());
    _checkNow();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkNow() async {
    if (_checking || _navigated || _starting) return;
    _checking = true;
    try {
      await _cubit.refresh(widget.args.orderId);
    } finally {
      _checking = false;
    }
    if (!mounted) return;

    final phase = _cubit.state.phase;
    if (phase == PaymobPaymentPhase.confirmed ||
        phase == PaymobPaymentPhase.failed) {
      _stopPolling();
      return;
    }

    final deadline = _pollDeadline;
    if (deadline != null &&
        DateTime.now().isAfter(deadline) &&
        phase == PaymobPaymentPhase.awaiting) {
      _stopPolling();
      if (!_timedOut) setState(() => _timedOut = true);
    }
  }

  void _goToConfirmation() {
    if (!mounted || _navigated) return;
    _navigated = true;
    _stopPolling();
    unawaited(OrdersCubit.instance.load(force: true));
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.confirm, (_) => false);
  }

  void _leave() {
    if (!mounted) return;
    _navigated = true;
    _stopPolling();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.mainNav, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymobPaymentCubit, PaymobPaymentState>(
      bloc: _cubit,
      listenWhen: (previous, current) => previous.phase != current.phase,
      listener: (context, state) {
        if (state.isConfirmed) {
          _goToConfirmation();
        } else if (state.isFailed) {
          _stopPolling();
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 768;
              return Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(
                  child: wide ? _buildWeb(state) : _buildMobile(state),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMobile(PaymobPaymentState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          CustomAppBar.orchid(title: 'Card Payment', onBackPressed: _leave),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  PendingPanel(
                    state: state,
                    orderCode: widget.args.displayCode,
                    starting: _starting,
                    timedOut: _timedOut,
                    wide: false,
                  ),
                  SizedBox(height: 26.h),
                  PaymentPendingActions(
                    state: state,
                    wide: false,
                    starting: _starting,
                    onCheckNow: _checkNow,
                    onStart: _start,
                    onReopen: _reopen,
                    onLeave: _leave,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeb(PaymobPaymentState state) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 30, 40, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _leave,
                    icon: const Icon(Ionicons.arrow_back_outline),
                  ),
                  const SizedBox(width: 8),
                  const CustomText(
                    text: 'Card Payment',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.black,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PendingPanel(
                          state: state,
                          orderCode: widget.args.displayCode,
                          starting: _starting,
                          timedOut: _timedOut,
                          wide: true,
                        ),
                        const SizedBox(height: 26),
                        PaymentPendingActions(
                          state: state,
                          wide: true,
                          starting: _starting,
                          onCheckNow: _checkNow,
                          onStart: _start,
                          onReopen: _reopen,
                          onLeave: _leave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
