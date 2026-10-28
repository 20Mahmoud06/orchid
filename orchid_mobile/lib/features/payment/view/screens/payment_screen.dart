import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../features/checkout/cubit/checkout_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/message_option_card.dart';

/// Payment screen matching the Orchid Figma design.
class PaymentScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const PaymentScreen({super.key, this.onBackPressed});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    // A fresh payment screen always starts on cash, even if a previous
    // checkout attempt left another method selected.
    CheckoutCubit.instance.setPaymentMethod('cash');
  }

  Future<void> _onConfirm(BuildContext context) async {
    switch (CheckoutCubit.instance.state.paymentMethod) {
      case 'cash':
        await _showCashConfirmationDialog(context);
        break;
      case 'card':
        // Paymob Unified Checkout collects the card data on Paymob's page.
        // The app never handles or stores raw card details.
        await submitCheckoutAndConfirm(context, paymentMethod: 'card');
        break;
      case 'wallet':
        Navigator.pushNamed(context, AppRoutes.myWallet);
        break;
    }
  }

  Future<void> _showCashConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
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
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final selected = state.paymentMethod;
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
                            isSelected: selected == 'cash',
                            isEnabledStyle: true,
                            onTap: () =>
                                CheckoutCubit.instance.setPaymentMethod('cash'),
                          ),
                          SizedBox(height: 18.h),
                          MessageOptionCard(
                            customIcon: selected == 'card'
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
                            isSelected: selected == 'card',
                            isEnabledStyle: true,
                            onTap: () =>
                                CheckoutCubit.instance.setPaymentMethod('card'),
                          ),
                          SizedBox(height: 18.h),
                          MessageOptionCard(
                            icon: Ionicons.wallet_outline,
                            label: 'wallet',
                            isSelected: selected == 'wallet',
                            isEnabledStyle: true,
                            onTap: () => CheckoutCubit.instance
                                .setPaymentMethod('wallet'),
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
                    onPressed: () => _onConfirm(context),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
