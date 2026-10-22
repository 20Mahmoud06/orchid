import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Confirms canceling an active order, or removing a completed one.
Future<bool?> showCancelOrderDialog(
  BuildContext context, {
  required bool isCompleted,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => _HistoryConfirmationDialog(
      icon: isCompleted ? Ionicons.trash : Ionicons.close_circle_outline,
      title: isCompleted ? 'Remove from history?' : 'Cancel this order?',
      message: isCompleted
          ? 'Are you sure you want to remove this order from your history?'
          : 'Are you sure you want to cancel this order? It stays in your account marked as canceled.',
      confirmLabel: isCompleted ? 'REMOVE FROM HISTORY' : 'CANCEL ORDER',
      confirmFontSize: isCompleted ? 12.sp : 16.sp,
      onKeep: () => Navigator.of(ctx).pop(false),
      onConfirm: () => Navigator.of(ctx).pop(true),
    ),
  );
}

/// Confirms canceling every order in the history.
Future<bool?> showCancelAllOrdersDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => _HistoryConfirmationDialog(
      icon: Ionicons.trash,
      title: 'Cancel all orders?',
      message:
          'All your orders will be marked as canceled. They stay in your account and in the dashboard.',
      confirmLabel: 'CANCEL ALL',
      confirmFontSize: 16.sp,
      onKeep: () => Navigator.of(ctx).pop(false),
      onConfirm: () => Navigator.of(ctx).pop(true),
    ),
  );
}

class _HistoryConfirmationDialog extends StatelessWidget {
  const _HistoryConfirmationDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmFontSize,
    required this.onKeep,
    required this.onConfirm,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final double confirmFontSize;
  final VoidCallback onKeep;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.r, color: AppColors.redText),
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
              text: message,
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
                    label: 'KEEP',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.black,
                    backgroundColor: AppColors.white,
                    height: 48.h,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [],
                    onPressed: onKeep,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    label: confirmLabel,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: confirmFontSize,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.white,
                    backgroundColor: AppColors.canceledText,
                    height: 48.h,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [],
                    onPressed: onConfirm,
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
