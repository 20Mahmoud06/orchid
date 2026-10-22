import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

/// Desktop storefront brand mark: flower icon with uppercase serif 'ORCHID'.
class WebTopNavBrand extends StatelessWidget {
  final VoidCallback onTap;

  const WebTopNavBrand({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.flowerOutlineIcon,
              color: AppColors.storeRose,
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 10),
            const Text(
              'ORCHID',
              style: TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: AppColors.storeDeepGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
