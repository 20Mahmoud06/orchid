import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Orchid logo + wordmark header used at the top of every auth page.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.smallFlowerSplash,
          height: 56,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        const CustomText(
          text: 'ORCHID',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 42,
          height: 1,
          letterSpacing: 1.5,
          textColor: AppColors.darkGreen,
        ),
        const SizedBox(height: 3),
        const CustomText(
          text: 'flower shop',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.goudyBookletter,
          fontSize: 17,
          height: 1,
          letterSpacing: 0.5,
          textColor: AppColors.flowerShopGreen,
        ),
      ],
    );
  }
}
