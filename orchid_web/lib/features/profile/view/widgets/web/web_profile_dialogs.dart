import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first Profile dialogs.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile dialogs
/// in `profile_dialogs.dart` exactly. Sizing uses fixed logical pixels (not
/// `flutter_screenutil`) so these render 1:1 on any monitor — the same
/// convention as the other web modals (maxWidth 440, stacked 48px actions).

/// Log-out confirmation at web sizing. The confirm/cancel actions are supplied
/// by the caller so the mobile logic stays in one place.
class WebLogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onCancel;

  const WebLogoutDialog({
    super.key,
    required this.onLogout,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
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
                child: const Icon(
                  Icons.logout,
                  size: 32,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 18),
              const CustomText(
                text: 'Log Out',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.darkGreen,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const CustomText(
                text: 'are you sure you want to log out?',
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
                height: 1.4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const CustomText(
                    text: 'Log Out',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.darkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textFieldDarkerPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const CustomText(
                    text: 'Cancel',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.darkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Delete-account confirmation (confirm + success states) at web sizing.
///
/// The state itself (deleting/spinner, error message, success) is owned by
/// `showDeleteAccountDialog`; this widget only renders it, mirroring the mobile
/// dialog one-to-one.
class WebDeleteAccountDialog extends StatelessWidget {
  final bool isDeleting;
  final bool deletionSucceeded;
  final String errorMessage;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final VoidCallback onBackToLogin;

  const WebDeleteAccountDialog({
    super.key,
    required this.isDeleting,
    required this.deletionSucceeded,
    required this.errorMessage,
    required this.onDelete,
    required this.onCancel,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: deletionSucceeded ? _successBody() : _confirmBody(),
          ),
        ),
      ),
    );
  }

  List<Widget> _successBody() {
    return [
      Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.greenBackground,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Ionicons.checkmark,
          size: 32,
          color: AppColors.darkGreen,
        ),
      ),
      const SizedBox(height: 18),
      const CustomText(
        text: 'Account Deleted',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        textColor: AppColors.darkGreen,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      const CustomText(
        text: 'your account has been deleted successfully.',
        fontFamily: AppFonts.inriaSerif,
        fontSize: 14,
        textColor: AppColors.textPrimary,
        textAlign: TextAlign.center,
        height: 1.4,
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onBackToLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const CustomText(
            text: 'Back to Login',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            textColor: AppColors.darkGreen,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ];
  }

  List<Widget> _confirmBody() {
    return [
      Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.redBackground,
          shape: BoxShape.circle,
        ),
        child: const Icon(Ionicons.trash, size: 32, color: AppColors.redText),
      ),
      const SizedBox(height: 18),
      const CustomText(
        text: 'Delete Account',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        textColor: AppColors.redText,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      const CustomText(
        text:
            'are you sure you want to permanently delete '
            'your account?\nthis action cannot be undone.',
        fontFamily: AppFonts.inriaSerif,
        fontSize: 14,
        textColor: AppColors.textPrimary,
        textAlign: TextAlign.center,
        height: 1.4,
      ),
      if (errorMessage.isNotEmpty) ...[
        const SizedBox(height: 12),
        CustomText(
          text: errorMessage,
          fontFamily: AppFonts.inriaSerif,
          fontSize: 12,
          textColor: AppColors.redText,
          textAlign: TextAlign.center,
        ),
      ],
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.canceledText,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const CustomText(
                  text: 'Delete',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.white,
                  letterSpacing: 0.5,
                ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textFieldDarkerPink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const CustomText(
            text: 'Cancel',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            textColor: AppColors.darkGreen,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ];
  }
}
