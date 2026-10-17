import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'account_section_tile.dart';

/// "Account" section title plus the Privacy Policy / Terms / About tiles.
class ProfileAccountSection extends StatelessWidget {
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsConditions;
  final VoidCallback onAboutApp;

  const ProfileAccountSection({
    super.key,
    required this.onPrivacyPolicy,
    required this.onTermsConditions,
    required this.onAboutApp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
          child: CustomText(
            text: 'Account',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.cardBorder, width: 1.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccountSectionTile(
                icon: Image.asset(
                  AppAssets.privacyIcon,
                  width: 24.r,
                  height: 24.r,
                  fit: BoxFit.contain,
                ),
                title: 'Privacy Policy',
                onTap: onPrivacyPolicy,
              ),
              AccountSectionTile(
                icon: Image.asset(
                  AppAssets.termsIcon,
                  width: 24.r,
                  height: 24.r,
                  fit: BoxFit.contain,
                ),
                title: 'Terms & Conditions',
                onTap: onTermsConditions,
              ),
              AccountSectionTile(
                icon: Image.asset(
                  AppAssets.aboutIcon,
                  width: 24.r,
                  height: 24.r,
                  fit: BoxFit.contain,
                ),
                title: 'About App',
                onTap: onAboutApp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
