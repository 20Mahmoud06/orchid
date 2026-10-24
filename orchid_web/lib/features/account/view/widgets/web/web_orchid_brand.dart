import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// ORCHID flower + wordmark used at the top of the About page.
class WebOrchidBrand extends StatelessWidget {
  const WebOrchidBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.smallFlowerSplash,
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 2),
        const CustomText(
          text: 'ORCHID',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 42,
          fontWeight: FontWeight.w400,
          height: 1.0,
          letterSpacing: -0.84,
          textColor: AppColors.darkGreen,
          shadows: [
            Shadow(
              offset: Offset(4, 4),
              blurRadius: 7,
              color: Color(0x40000000),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const CustomText(
          text: 'flower shop',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.goudyBookletter,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.0,
          letterSpacing: -0.36,
          textColor: AppColors.flowerShopGreen,
          shadows: [
            Shadow(
              offset: Offset(0, 4),
              blurRadius: 4,
              color: Color(0x40000000),
            ),
          ],
        ),
      ],
    );
  }
}
