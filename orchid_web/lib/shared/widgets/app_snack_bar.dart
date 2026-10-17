import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/utils/viewport.dart';
import 'custom_text.dart';

/// Shared Orchid snackbar used across the app.
///
/// On the web the floating snackbar is width-constrained and centered so the
/// message reads as a small toast instead of a bar spanning the whole browser;
/// the mobile layout keeps Flutter's full-width default.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  showAppSnackBarWith(messenger, message, isError: isError);
}

/// Same as [showAppSnackBar] but for callers that only hold the
/// [ScaffoldMessengerState] (e.g. the app-level `scaffoldMessengerKey`).
void showAppSnackBarWith(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
}) {
  // Dialogs/snackbars sit above the pinned phone `MediaQuery`, so the desktop
  // decision reads the real viewport (see `viewportWidth`).
  final isWebViewport = isWideViewport(messenger.context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: isWebViewport ? 420 : null,
        backgroundColor: isError ? AppColors.error : AppColors.darkGreen,
        shape: RoundedRectangleBorder(
          // Fixed logical radius on the web layout — ScreenUtil would
          // otherwise scale .r with the pinned phone width.
          borderRadius: BorderRadius.circular(isWebViewport ? 12 : 12.r),
        ),
        content: CustomText(
          text: message,
          fontFamily: AppFonts.inriaSerif,
          // Fixed logical size on the web layout, mobile keeps 14.sp.
          fontSize: isWebViewport ? 14 : 14.sp,
          textColor: AppColors.white,
          textAlign: isWebViewport ? TextAlign.center : TextAlign.start,
        ),
      ),
    );
}
