import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/bouquet_options_dialog.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../cubit/cart_cubit.dart';

/// Opens the shared bouquet chooser so the user can buy an existing bouquet
/// or create their own — used by both the empty cart and "add more items".
void showChooseBouquetDialog(BuildContext context, {required String title}) {
  showBouquetOptionsDialog(
    context,
    title: title,
    description: 'Buy an existing bouquet or create your own.',
    onBuyExisting: () => Navigator.pushNamed(context, AppRoutes.chooseBouquets),
    onCreateCustom: () => Navigator.pushNamed(context, AppRoutes.chooseFlowers),
  );
}

/// Shows a confirmation dialog before clearing the entire cart.
void showClearCartDialog(BuildContext context, CartCubit cart) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return PopScope(
        canPop: true,
        child: Dialog(
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
                  decoration: const BoxDecoration(
                    color: AppColors.redBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.trash,
                    size: 32.r,
                    color: AppColors.redText,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Clear Cart',
                  textAlign: TextAlign.center,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.redText,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text:
                      'are you sure you want to remove all items '
                      'from your cart?\nthis action cannot be undone.',
                  textAlign: TextAlign.center,
                  fontSize: 14.sp,
                  textColor: AppColors.textPrimary,
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  label: 'Delete All',
                  height: 48.h,
                  borderRadius: BorderRadius.circular(14.r),
                  backgroundColor: AppColors.canceledText,
                  textColor: AppColors.white,
                  onPressed: () {
                    cart.clearCart();
                    Navigator.of(ctx).pop();
                  },
                ),
                SizedBox(height: 12.h),
                CustomButton(
                  label: 'Cancel',
                  height: 48.h,
                  borderRadius: BorderRadius.circular(14.r),
                  backgroundColor: AppColors.textFieldDarkerPink,
                  textColor: AppColors.darkGreen,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
