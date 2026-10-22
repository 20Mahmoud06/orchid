import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/message_option_card.dart';
import '../../models/payment_method.dart';

/// Mobile layout of the payment screen (unchanged presentation).
class PaymentMobileView extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onMethodSelected;
  final VoidCallback onConfirm;
  final VoidCallback? onBackPressed;

  const PaymentMobileView({
    super.key,
    required this.selected,
    required this.onMethodSelected,
    required this.onConfirm,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(
                title: 'Order Summary',
                onBackPressed: onBackPressed,
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
                        isSelected: selected == PaymentMethod.cash,
                        isEnabledStyle: true,
                        onTap: () => onMethodSelected(PaymentMethod.cash),
                      ),
                      SizedBox(height: 18.h),
                      MessageOptionCard(
                        customIcon: selected == PaymentMethod.card
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
                        isSelected: selected == PaymentMethod.card,
                        isEnabledStyle: true,
                        onTap: () => onMethodSelected(PaymentMethod.card),
                      ),
                      SizedBox(height: 18.h),
                      MessageOptionCard(
                        icon: Ionicons.wallet_outline,
                        label: 'wallet',
                        isSelected: selected == PaymentMethod.wallet,
                        isEnabledStyle: true,
                        onTap: () => onMethodSelected(PaymentMethod.wallet),
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
                onPressed: onConfirm,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
