import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Closing message card (Privacy and Terms pages): a flower, a titled divider
/// row and a heart.
class WebAccountFooter extends StatelessWidget {
  final String title;
  final String description;

  const WebAccountFooter({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.smallFlowerSplash,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(text: title, style: titleStyle),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();
                final titleWidth = textPainter.width.clamp(
                  0.0,
                  constraints.maxWidth,
                );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: title,
                      textAlign: TextAlign.center,
                      style: titleStyle.copyWith(
                        color: AppColors.thanksYouText,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                          CustomText(
                            text: description,
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
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
