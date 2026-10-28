import 'dart:async';
import 'package:ORCHID/features/payment/widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../order/cubit/orders_cubit.dart';
import '../../cubit/paymob_payment_cubit.dart';
import '../../cubit/paymob_payment_state.dart';
import '../../data/paymob_checkout_launcher.dart';

/// Arguments for the card-payment status screen.
class PaymentPendingArgs {
  const PaymentPendingArgs({required this.orderId, required this.orderCode});

  final String orderId;
  final String orderCode;

  String get displayCode => orderCode.isEmpty ? '' : '#$orderCode';
}

/// Shown after the Paymob checkout page is launched. It polls the backend
/// (never the browser redirect) and only navigates to the confirmation screen
/// once the webhook has marked the order paid.
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
    // Mobile returns from the in-app browser; web returns from the Paymob tab.
    if (state == AppLifecycleState.resumed) {
      _checkNow();
    }
  }

  /// Checks the server before starting anything. This covers a reload, a
  /// cold app start, a return from the Paymob page and the Resume Payment
  /// action in order history: an already-paid order goes to confirmation, and
  /// a quarantined Paymob outcome never opens a second chargeable checkout.
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
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    CustomAppBar.orchid(
                      title: 'Card Payment',
                      onBackPressed: _leave,
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 12.h),
                            StatusCard(
                              state: state,
                              orderCode: widget.args.displayCode,
                              starting: _starting,
                              timedOut: _timedOut,
                            ),
                            SizedBox(height: 26.h),
                            ..._buildActions(state),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActions(PaymobPaymentState state) {
    if (state.phase == PaymobPaymentPhase.creating || _starting) {
      return const [];
    }

    final quarantined = state.snapshot?.isQuarantined == true;
    final reviewing = state.snapshot?.needsReview == true;
    if (quarantined || reviewing) {
      return [
        CustomButton(
          label: 'CHECK AGAIN',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.textFieldPink,
          height: 52.h,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [],
          onPressed: _checkNow,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          label: 'BACK TO HOME',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.white,
          height: 48.h,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: const [],
          onPressed: _leave,
        ),
      ];
    }

    if (state.phase == PaymobPaymentPhase.error ||
        state.phase == PaymobPaymentPhase.failed) {
      return [
        CustomButton(
          label: 'TRY AGAIN',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.textFieldPink,
          height: 52.h,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [],
          onPressed: _start,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          label: 'BACK TO HOME',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.white,
          height: 48.h,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: const [],
          onPressed: _leave,
        ),
      ];
    }

    return [
      CustomButton(
        label: 'CHECK AGAIN',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        textColor: AppColors.black,
        backgroundColor: AppColors.textFieldPink,
        height: 52.h,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [],
        onPressed: _checkNow,
      ),
      SizedBox(height: 12.h),
      CustomButton(
        label: 'REOPEN PAYMENT PAGE',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        textColor: AppColors.black,
        backgroundColor: AppColors.white,
        height: 48.h,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [],
        onPressed: _reopen,
      ),
      SizedBox(height: 12.h),
      TextButton(
        onPressed: _leave,
        child: CustomText(
          text: 'Back to home',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16.sp,
          textColor: AppColors.textPrimary,
        ),
      ),
    ];
  }
}
