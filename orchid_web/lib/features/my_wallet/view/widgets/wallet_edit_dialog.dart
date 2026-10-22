import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_provider.dart';

class WalletEditDialog extends StatelessWidget {
  const WalletEditDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hint,
    this.keyboardType,
    required this.provider,
    required this.isProviderSelected,
    this.icon,
  });

  final String title;
  final String initialValue;
  final String hint;
  final TextInputType? keyboardType;
  final WalletProvider provider;
  final bool isProviderSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
                color: isProviderSelected
                    ? provider.lightColor
                    : AppColors.incrementButton.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Ionicons.cash_outline,
                size: 32.r,
                color: isProviderSelected
                    ? provider.brandColor
                    : AppColors.textGrey,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: title,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              textColor: AppColors.black,
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: hint,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: controller,
              keyboardType: keyboardType ?? TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isProviderSelected
                        ? provider.brandColor.withValues(alpha: 0.3)
                        : AppColors.incrementButton.withValues(alpha: 0.3),
                    width: 1.5.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isProviderSelected
                        ? provider.brandColor.withValues(alpha: 0.3)
                        : AppColors.incrementButton.withValues(alpha: 0.3),
                    width: 1.5.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isProviderSelected
                        ? provider.brandColor
                        : AppColors.incrementButton,
                    width: 2.w,
                  ),
                ),
              ),
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    label: 'SAVE',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.black,
                    backgroundColor: isProviderSelected
                        ? provider.lightColor
                        : AppColors.textFieldPink,
                    height: 48.h,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [],
                    onPressed: () =>
                        Navigator.of(context).pop(controller.text.trim()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
