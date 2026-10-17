import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../auth/data/models/user_profile_model.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'profile_avatar.dart';
import 'profile_info_tile.dart';

/// The rounded profile card at the top of the Profile screen: tappable avatar,
/// name/email, an Edit button and the info rows.
class ProfileHeaderCard extends StatelessWidget {
  final String displayName;
  final String displayEmail;
  final String? imageUrl;
  final UserProfileModel? profile;
  final VoidCallback onEdit;

  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.displayEmail,
    required this.imageUrl,
    required this.profile,
    required this.onEdit,
  });

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1.w,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14.h,
            left: 14.w,
            right: 14.w,
            child: Row(
              children: [
                InkWell(
                  onTap: onEdit,
                  customBorder: const CircleBorder(),
                  child: Stack(
                    children: [
                      Container(
                        width: 90.r,
                        height: 90.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.5.w,
                          ),
                        ),
                        child: ClipOval(
                          child: ProfileAvatarImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26.r,
                          height: 26.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black12,
                              width: 1.w,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16.r,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: displayName,
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.black,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: displayEmail,
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 12.sp,
                        textColor: Colors.black.withValues(alpha: 0.75),
                      ),
                      SizedBox(height: 6.h),
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: CustomText(
                            text: 'Edit',
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            textColor: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 120.h,
            left: -1.w,
            right: -1.w,
            bottom: -10.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1.w,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileInfoTile(
                    label: 'Username',
                    value: _displayValue(profile?.username),
                  ),
                  ProfileInfoTile(
                    label: 'Phone Number',
                    value: _displayValue(profile?.phone),
                  ),
                  ProfileInfoTile(
                    label: 'Whatsapp Number',
                    value: _displayValue(profile?.whatsapp),
                  ),
                  ProfileInfoTile(
                    label: 'Delivery Address',
                    value: _displayValue(profile?.address),
                    showArrow: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
