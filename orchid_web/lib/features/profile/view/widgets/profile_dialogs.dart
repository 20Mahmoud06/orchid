import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/viewport.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'web/web_profile_dialogs.dart';

/// Confirmation dialog for logging out; signs out and returns to login.
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      Future<void> handleLogout() async {
        Navigator.of(ctx).pop();
        await AuthCubit.instance.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      }

      // Desktop web presentation; dialogs have no LayoutBuilder, so the
      // desktop decision reads the real viewport. Narrow viewports keep the
      // untouched mobile dialog.
      if (isWideViewport(ctx)) {
        return WebLogoutDialog(
          onLogout: handleLogout,
          onCancel: () => Navigator.of(ctx).pop(),
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
                decoration: const BoxDecoration(
                  color: AppColors.textFieldPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 32.r,
                  color: AppColors.darkGreen,
                ),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: 'Log Out',
                textAlign: TextAlign.center,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                textColor: AppColors.darkGreen,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: 'are you sure you want to log out?',
                textAlign: TextAlign.center,
                fontSize: 14.sp,
                textColor: AppColors.textPrimary,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                label: 'Log Out',
                height: 48.h,
                borderRadius: BorderRadius.circular(14.r),
                onPressed: handleLogout,
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
      );
    },
  );
}

/// Confirmation dialog for permanently deleting the account.
void showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      var isDeleting = false;
      var errorMessage = '';
      var deletionSucceeded = false;

      return PopScope(
        canPop: true,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> handleDelete() async {
              setDialogState(() {
                isDeleting = true;
                errorMessage = '';
              });
              final error = await AuthCubit.instance.deleteAccount();
              if (!ctx.mounted) return;
              if (error != null) {
                setDialogState(() {
                  isDeleting = false;
                  errorMessage = error;
                });
                return;
              }
              setDialogState(() {
                isDeleting = false;
                deletionSucceeded = true;
              });
            }

            void handleBackToLogin() {
              Navigator.of(ctx).pop();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            }

            // Desktop web presentation; dialogs have no LayoutBuilder, so the
            // desktop decision reads the real viewport. Narrow viewports keep
            // the untouched mobile dialog.
            if (isWideViewport(ctx)) {
              return WebDeleteAccountDialog(
                isDeleting: isDeleting,
                deletionSucceeded: deletionSucceeded,
                errorMessage: errorMessage,
                onDelete: isDeleting ? null : handleDelete,
                onCancel: isDeleting ? null : () => Navigator.of(ctx).pop(),
                onBackToLogin: handleBackToLogin,
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
                  children: deletionSucceeded
                      ? [
                          Container(
                            width: 64.r,
                            height: 64.r,
                            decoration: const BoxDecoration(
                              color: AppColors.greenBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Ionicons.checkmark,
                              size: 32.r,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          CustomText(
                            text: 'Account Deleted',
                            textAlign: TextAlign.center,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.darkGreen,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'your account has been deleted successfully.',
                            textAlign: TextAlign.center,
                            fontSize: 14.sp,
                            textColor: AppColors.textPrimary,
                          ),
                          SizedBox(height: 24.h),
                          CustomButton(
                            label: 'Back to Login',
                            height: 48.h,
                            borderRadius: BorderRadius.circular(14.r),
                            onPressed: handleBackToLogin,
                          ),
                        ]
                      : [
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
                            text: 'Delete Account',
                            textAlign: TextAlign.center,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.redText,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text:
                                'are you sure you want to permanently delete '
                                'your account?\nthis action cannot be undone.',
                            textAlign: TextAlign.center,
                            fontSize: 14.sp,
                            textColor: AppColors.textPrimary,
                          ),
                          if (errorMessage.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            CustomText(
                              text: errorMessage,
                              textAlign: TextAlign.center,
                              fontSize: 12.sp,
                              textColor: AppColors.redText,
                            ),
                          ],
                          SizedBox(height: 24.h),
                          CustomButton(
                            label: 'Delete',
                            height: 48.h,
                            borderRadius: BorderRadius.circular(14.r),
                            backgroundColor: AppColors.canceledText,
                            textColor: AppColors.white,
                            isLoading: isDeleting,
                            onPressed: isDeleting ? null : handleDelete,
                          ),
                          SizedBox(height: 12.h),
                          CustomButton(
                            label: 'Cancel',
                            height: 48.h,
                            borderRadius: BorderRadius.circular(14.r),
                            backgroundColor: AppColors.textFieldDarkerPink,
                            textColor: AppColors.darkGreen,
                            onPressed: isDeleting
                                ? null
                                : () => Navigator.of(ctx).pop(),
                          ),
                        ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
