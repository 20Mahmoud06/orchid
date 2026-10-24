import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/skeleton_image.dart';

/// Circular-ready profile image. Shows the remote [imageUrl] when available
/// (a shimmering skeleton while downloading, the bundled placeholder on
/// failure), otherwise the bundled placeholder asset.
class ProfileAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;

  const ProfileAvatarImage({super.key, this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return SkeletonImage(
        path: AppAssets.placeholderProfile,
        fit: fit,
        errorWidget: const SkeletonFallbackBox(),
      );
    }

    return SkeletonImage(
      path: url,
      fit: fit,
      errorWidget: SkeletonImage(
        path: AppAssets.placeholderProfile,
        fit: fit,
        errorWidget: const SkeletonFallbackBox(),
      ),
    );
  }
}
