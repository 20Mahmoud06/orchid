import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import 'profile_avatar.dart';

/// Tappable avatar used by the Edit Profile screen. Shows the newly picked
/// [profileImage] while editing, otherwise the existing remote image.
class EditProfileAvatar extends StatelessWidget {
  final XFile? profileImage;
  final String? existingImageUrl;
  final VoidCallback onTap;

  const EditProfileAvatar({
    super.key,
    required this.profileImage,
    required this.existingImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.cardBorder, width: 2.w),
              ),
              child: ClipOval(
                child: profileImage != null
                    ? SkeletonImage(
                        path: profileImage!.path,
                        source: SkeletonImageSource.file,
                        fit: BoxFit.cover,
                        errorWidget: const ProfileAvatarImage(),
                      )
                    : ProfileAvatarImage(imageUrl: existingImageUrl),
              ),
            ),
            Positioned(
              bottom: 2.h,
              right: 2.w,
              child: Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1.w),
                ),
                child: Icon(Icons.camera_alt, size: 13.r, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
