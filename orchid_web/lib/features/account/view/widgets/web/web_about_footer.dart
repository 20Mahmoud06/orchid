import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// "More than flowers / It is a feeling" closing card (About page).
class WebAboutFooter extends StatelessWidget {
  const WebAboutFooter({super.key});

  @override
  Widget build(BuildContext context) {
    const titleText = 'More than flowers';
    const titleStyle = TextStyle(
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.privacyBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: const TextSpan(text: titleText, style: titleStyle),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout();
              final titleWidth = textPainter.width.clamp(
                0.0,
                constraints.maxWidth,
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: titleText,
                    textAlign: TextAlign.center,
                    style: titleStyle.copyWith(color: AppColors.thanksYouText),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: titleWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.thanksYouText,
                            thickness: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CustomText(
                          text: 'It is a feeling',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.black,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Divider(
                            color: AppColors.thanksYouText,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppAssets.heartIcon,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          right: -8,
          top: 35,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              AppAssets.bigFlowerSplash,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
