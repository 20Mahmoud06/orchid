import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../features/checkout/cubit/checkout_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';

class CheckoutSummary extends StatelessWidget {
  final int total;
  final VoidCallback? onConfirmOrder;

  const CheckoutSummary({super.key, required this.total, this.onConfirmOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'TOTAL',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              CustomText(
                text: '$total EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.selectedCategory,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          CustomButton(
            label: 'CONFIRM ORDER',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            textColor: AppColors.black,
            backgroundColor: AppColors.textFieldPink,
            height: 52.h,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [],
            onPressed:
                onConfirmOrder ??
                () {
                  CheckoutCubit.instance.beginCheckout(CheckoutSource.cart);
                  Navigator.pushNamed(context, AppRoutes.deliveryDetails);
                },
          ),
        ],
      ),
    );
  }
}
