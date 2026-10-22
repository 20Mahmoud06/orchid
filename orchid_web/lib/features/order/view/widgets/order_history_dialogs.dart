import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'web/web_cancel_order_dialog.dart';

/// Cancel confirmation for a single order. Pops `true` when the shopper
/// confirms. Desktop web presentation; narrow viewports keep the mobile dialog.
Future<bool?> showCancelOrderDialog(
  BuildContext context, {
  required bool isCompleted,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      if (isWideViewport(ctx)) {
        return WebCancelOrderDialog(
          icon: isCompleted ? Ionicons.trash : Ionicons.close_circle_outline,
          title: isCompleted ? 'Remove from history?' : 'Cancel this order?',
          message: isCompleted
              ? 'Are you sure you want to remove this order from your history?'
              : 'Are you sure you want to cancel this order? It stays in your account marked as canceled.',
          confirmLabel: isCompleted ? 'REMOVE FROM HISTORY' : 'CANCEL ORDER',
        );
      }
      return OrderCancelMobileDialog(
        icon: isCompleted ? Ionicons.trash : Ionicons.close_circle_outline,
        title: isCompleted ? 'Remove from history?' : 'Cancel this order?',
        message: isCompleted
            ? 'Are you sure you want to remove this order from your history?'
            : 'Are you sure you want to cancel this order? It stays in your account marked as canceled.',
        confirmLabel: isCompleted ? 'REMOVE FROM HISTORY' : 'CANCEL ORDER',
      );
    },
  );
}

/// Cancel confirmation for every order in the account. Pops `true` when the
/// shopper confirms. Desktop web presentation; narrow viewports keep the
/// mobile dialog.
Future<bool?> showCancelAllOrdersDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      if (isWideViewport(ctx)) {
        return const WebCancelOrderDialog(
          icon: Ionicons.trash,
          title: 'Cancel all orders?',
          message:
              'All your orders will be marked as canceled. They stay in your account and in the dashboard.',
          confirmLabel: 'CANCEL ALL',
        );
      }
      return const OrderCancelMobileDialog(
        icon: Ionicons.trash,
        title: 'Cancel all orders?',
        message:
            'All your orders will be marked as canceled. They stay in your account and in the dashboard.',
        confirmLabel: 'CANCEL ALL',
      );
    },
  );
}

/// Mobile cancel confirmation dialog (unchanged presentation).
class OrderCancelMobileDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;

  const OrderCancelMobileDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

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
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    label: confirmLabel,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: confirmLabel.length > 14 ? 12.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.white,
                    backgroundColor: AppColors.canceledText,
                    height: 48.h,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [],
                    onPressed: () => Navigator.of(context).pop(true),
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
