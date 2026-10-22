import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/features/profile/view/widgets/profile_avatar.dart';

/// Tappable profile avatar with an edit affordance badge.
class WebProfileCardAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const WebProfileCardAvatar({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 15,
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
