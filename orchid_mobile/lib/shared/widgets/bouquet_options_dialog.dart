import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_button.dart';
import 'custom_text.dart';

/// Reusable chooser dialog with a circular icon, a title, a description and
/// two stacked actions: buy an existing bouquet or create a custom one.
///
/// The copy and icon are supplied by the caller so each entry point shows
/// suitable text.
Future<void> showBouquetOptionsDialog(
  BuildContext context, {
  required String title,
  required String description,
  required VoidCallback onBuyExisting,
  required VoidCallback onCreateCustom,
  IconData icon = Ionicons.flower_outline,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BouquetOptionsDialog(
      title: title,
      description: description,
      icon: icon,
      onBuyExisting: () {
        Navigator.of(dialogContext).pop();
        onBuyExisting();
      },
      onCreateCustom: () {
        Navigator.of(dialogContext).pop();
        onCreateCustom();
      },
    ),
  );
}

class BouquetOptionsDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onBuyExisting;
  final VoidCallback onCreateCustom;

  const BouquetOptionsDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onBuyExisting,
    required this.onCreateCustom,
  });

  @override
  Widget build(BuildContext context) {
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
              decoration: const BoxDecoration(
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.r, color: AppColors.black),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: title,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              textColor: AppColors.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: description,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              label: 'BUY EXISTING BOUQUET',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              textColor: AppColors.black,
              backgroundColor: AppColors.textFieldPink,
              height: 48.h,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [],
              onPressed: onBuyExisting,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              label: 'CREATE MY BOUQUET',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              textColor: AppColors.black,
              backgroundColor: AppColors.white,
              height: 48.h,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [],
              onPressed: onCreateCustom,
            ),
          ],
        ),
      ),
    );
  }
}
