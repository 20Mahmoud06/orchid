import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_button.dart';
import 'custom_text.dart';

/// Reusable bottom-sheet-style chooser dialog with a circular icon, a title, a
/// description and two stacked actions.
///
/// [web] selects the desktop-first sizing (fixed logical pixels) used by the web
/// pages; otherwise the mobile screenutil sizing is used. The copy and icon are
/// supplied by the caller so each entry point shows suitable text.
Future<void> showBouquetOptionsDialog(
  BuildContext context, {
  required bool web,
  required String title,
  required String description,
  required VoidCallback onBuyExisting,
  required VoidCallback onCreateCustom,
  IconData icon = Ionicons.flower_outline,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BouquetOptionsDialog(
      web: web,
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
  final bool web;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onBuyExisting;
  final VoidCallback onCreateCustom;

  const BouquetOptionsDialog({
    super.key,
    required this.web,
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
        borderRadius: BorderRadius.circular(web ? 20 : 20.r),
      ),
      backgroundColor: AppColors.background,
      child: web ? _buildWeb() : _buildMobile(),
    );
  }

  Widget _buildWeb() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.black),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onBuyExisting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textFieldPink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BUY EXISTING BOUQUET',
                  style: TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onCreateCustom,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.storeOutlineBorder),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CREATE MY BOUQUET',
                  style: TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Padding(
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
    );
  }
}
