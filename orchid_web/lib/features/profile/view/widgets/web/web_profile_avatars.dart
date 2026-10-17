import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import '../profile_avatar.dart';

/// Desktop-first profile avatars for the Complete/Edit Profile web cards.
///
/// Presentation only: identical visuals to the mobile `CompleteProfileAvatar`
/// and `EditProfileAvatar`, sized in fixed logical pixels (not
/// `flutter_screenutil`) so they render 1:1 on any monitor.

/// Tappable avatar for the web Complete Profile card. Shows the newly picked
/// [profileImage], otherwise the bundled placeholder.
class WebCompleteProfileAvatar extends StatelessWidget {
  final XFile? profileImage;
  final VoidCallback onTap;

  const WebCompleteProfileAvatar({
    super.key,
    required this.profileImage,
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
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.fieldPink,
              ),
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: profileImage != null
                    ? SkeletonImage(
                        path: profileImage!.path,
                        source: SkeletonImageSource.file,
                        fit: BoxFit.cover,
                        errorWidget: const _WebPlaceholderAvatar(),
                      )
                    : const _WebPlaceholderAvatar(),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebPlaceholderAvatar extends StatelessWidget {
  const _WebPlaceholderAvatar();

  @override
  Widget build(BuildContext context) {
    return SkeletonImage(
      path: AppAssets.placeholderProfile,
      fit: BoxFit.contain,
      errorWidget: const SkeletonFallbackBox(),
    );
  }
}

/// Tappable avatar for the web Edit Profile card. Shows the newly picked
/// [profileImage], otherwise the existing remote image.
class WebEditProfileAvatar extends StatelessWidget {
  final XFile? profileImage;
  final String? existingImageUrl;
  final VoidCallback onTap;

  const WebEditProfileAvatar({
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.cardBorder, width: 2),
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
              bottom: 2,
              right: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 13,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
