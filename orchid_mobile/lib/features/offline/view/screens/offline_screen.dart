import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Wraps the whole app and monitors connectivity with [flutter_offline].
/// When the device goes offline, a full-screen overlay replaces the app UI
/// showing the offline image and a "Try again" button that opens the WiFi
/// settings screen.
class OfflineWrapper extends StatelessWidget {
  final Widget child;

  const OfflineWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      child: child,
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        final bool isOffline =
            !connectivity.any((result) => result != ConnectivityResult.none);
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (isOffline) const OfflineScreen(),
          ],
        );
      },
    );
  }
}

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  Future<void> _openWiFiSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.wifi);
    } catch (error) {
      debugPrint('[offline] failed to open wifi settings (error: $error)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Image.asset(
                    AppAssets.offline,
                    width: 400.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 40.h,
                child: CustomButton(
                  label: 'Try Again',
                  fontFamily: AppFonts.inriaSerif,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  borderRadius: BorderRadius.circular(24.r),
                  onPressed: _openWiFiSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}