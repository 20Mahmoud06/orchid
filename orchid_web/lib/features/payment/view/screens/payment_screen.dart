import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/message_option_card.dart';
import '../widgets/web/web_payment_widgets.dart';

enum PaymentMethod { cash, card, wallet }

/// Payment screen matching the Orchid Figma design.
class PaymentScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const PaymentScreen({super.key, this.onBackPressed});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selected = PaymentMethod.cash;

  Future<void> _onConfirm() async {
    switch (_selected) {
      case PaymentMethod.cash:
        await _showCashConfirmationDialog(context);
        break;
      case PaymentMethod.card:
        Navigator.pushNamed(context, AppRoutes.myCard);
        break;
      case PaymentMethod.wallet:
        Navigator.pushNamed(context, AppRoutes.myWallet);
        break;
    }
  }

  Future<void> _showCashConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        // The web build pins `MediaQuery.size` to the phone design size, so the
        // desktop decision has to read the real viewport. Mobile is unchanged.
        if (isWideViewport(ctx)) {
          return WebCashConfirmationDialog(
            onCancel: () => Navigator.of(ctx).pop(),
            onConfirm: () {
              Navigator.of(ctx).pop();
              submitCheckoutAndConfirm(context, paymentMethod: 'cash');
            },
          );
        }
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.textFieldPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.cash_outline,
                    size: 32.r,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Confirm Cash Payment',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text:
                      'You will pay in cash upon delivery. Do you want to confirm this order?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14.sp,
                  textColor: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'CANCEL',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.white,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        label: 'CONFIRM',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.textFieldPink,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          submitCheckoutAndConfirm(
                            context,
                            paymentMethod: 'cash',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first payment page (>= 768px). Same colors, copy and behaviour as
  /// the mobile screen — a two-column layout like "my cart": the payment
  /// illustration on the left and the three method cards on the right, with the
  /// CONFIRM action centered below both columns.
  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebPaymentHeader(onBackPressed: widget.onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.30)
                            .clamp(280.0, 380.0);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WebPaymentIllustrationCard(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 28),
                                  SizedBox(
                                    width: sideWidth,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WebPaymentMethodCard(
                                            icon: Ionicons.cash_outline,
                                            label: 'cash',
                                            isSelected:
                                                _selected == PaymentMethod.cash,
                                            onTap: () => setState(
                                              () => _selected =
                                                  PaymentMethod.cash,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          WebPaymentMethodCard(
                                            customIcon: Image.asset(
                                              _selected == PaymentMethod.card
                                                  ? AppAssets.visaBlackIcon
                                                  : AppAssets.visaGreyIcon,
                                              width: 30,
                                              height: 30,
                                            ),
                                            label: 'credit \\ debit card',
                                            isSelected:
                                                _selected == PaymentMethod.card,
                                            onTap: () => setState(
                                              () => _selected =
                                                  PaymentMethod.card,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          WebPaymentMethodCard(
                                            icon: Ionicons.wallet_outline,
                                            label: 'wallet',
                                            isSelected:
                                                _selected ==
                                                PaymentMethod.wallet,
                                            onTap: () => setState(
                                              () => _selected =
                                                  PaymentMethod.wallet,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                width: 320,
                                child: CustomButton(
                                  label: 'CONFIRM',
                                  fontFamily: AppFonts.goudyOldStyle,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.black,
                                  backgroundColor: AppColors.textFieldPink,
                                  height: 52,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [],
                                  onPressed: _onConfirm,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(
                title: 'Order Summary',
                onBackPressed: widget.onBackPressed,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.incrementButton,
                            width: 1.w,
                          ),
                        ),
                        child: Image.asset(
                          AppAssets.payment,
                          width: 300.w,
                          height: 300.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      MessageOptionCard(
                        icon: Ionicons.cash_outline,
                        label: 'cash',
                        isSelected: _selected == PaymentMethod.cash,
                        isEnabledStyle: true,
                        onTap: () =>
                            setState(() => _selected = PaymentMethod.cash),
                      ),
                      SizedBox(height: 18.h),
                      MessageOptionCard(
                        customIcon: _selected == PaymentMethod.card
                            ? Image.asset(
                                AppAssets.visaBlackIcon,
                                width: 30.w,
                                height: 30.h,
                              )
                            : Image.asset(
                                AppAssets.visaGreyIcon,
                                width: 30.w,
                                height: 30.h,
                              ),
                        label: 'credit \\ debit card',
                        isSelected: _selected == PaymentMethod.card,
                        isEnabledStyle: true,
                        onTap: () =>
                            setState(() => _selected = PaymentMethod.card),
                      ),
                      SizedBox(height: 18.h),
                      MessageOptionCard(
                        icon: Ionicons.wallet_outline,
                        label: 'wallet',
                        isSelected: _selected == PaymentMethod.wallet,
                        isEnabledStyle: true,
                        onTap: () =>
                            setState(() => _selected = PaymentMethod.wallet),
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                label: 'CONFIRM',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.black,
                backgroundColor: AppColors.textFieldPink,
                height: 52.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: _onConfirm,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
