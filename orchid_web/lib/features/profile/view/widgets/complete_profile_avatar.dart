import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/skeleton_image.dart';

/// Tappable avatar used by the Complete Profile screen. Shows the newly picked
/// [profileImage] while completing the profile, otherwise the bundled
/// placeholder.
class CompleteProfileAvatar extends StatelessWidget {
  final XFile? profileImage;
  final VoidCallback onTap;

  const CompleteProfileAvatar({
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
              width: 120.r,
              height: 120.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.fieldPink,
              ),
              padding: EdgeInsets.all(8.r),
              child: ClipOval(
                child: profileImage != null
                    ? SkeletonImage(
                        path: profileImage!.path,
                        source: SkeletonImageSource.file,
                        fit: BoxFit.cover,
                        errorWidget: const _PlaceholderAvatar(),
                      )
                    : const _PlaceholderAvatar(),
              ),
            ),
            Positioned(
              bottom: 4.h,
              right: 4.w,
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.camera_alt, size: 18.r, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar();

  @override
  Widget build(BuildContext context) {
    return SkeletonImage(
      path: AppAssets.placeholderProfile,
      fit: BoxFit.contain,
      errorWidget: const SkeletonFallbackBox(),
    );
  }
}
