import 'package:flutter/material.dart';
import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/home/view/widgets/web/web_pill_button.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Promotional section for the custom bouquet builder matching the reference image:
/// Blush pink banner with headline, description, button, and tulips on the right.

class WebCustomBouquetBanner extends StatelessWidget {
  const WebCustomBouquetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.storeBlush,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.storeBlushBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: isCompact ? _buildCompact(context) : _buildWide(context),
        );
      },
    );
  }

  Widget _buildWide(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 350,
          child: Stack(
            children: [
              // Flower image anchored to the bottom-right.
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                width: constraints.maxWidth * 0.48,
                child: Image.asset(
                  AppAssets.buildFlower,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),

              // Text and button.
              Positioned(
                left: 50,
                top: 0,
                bottom: 0,
                width: constraints.maxWidth * 0.52,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        text: 'Build a bouquet that feels like you',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.storeDeepGreen,
                      ),
                      const SizedBox(height: 8),
                      const CustomText(
                        text:
                            'Choose your favorite flowers, add a personal touch,\n'
                            'and create something truly special.',
                        fontFamily: AppFonts.inriaSerif,
                        fontSize: 13,
                        height: 1.35,
                        textColor: AppColors.storeBodyText,
                      ),
                      const SizedBox(height: 16),
                      WebPillButton(
                        label: 'Start creating  →',
                        filled: true,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.chooseFlowers,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Build a bouquet that feels like you',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            textColor: AppColors.storeDeepGreen,
          ),
          const SizedBox(height: 8),
          const CustomText(
            text:
                'Choose your favorite flowers, add a personal touch, '
                'and create something truly special.',
            fontFamily: AppFonts.inriaSerif,
            fontSize: 13,
            height: 1.35,
            textColor: AppColors.storeBodyText,
          ),
          const SizedBox(height: 16),
          WebPillButton(
            label: 'Start creating  →',
            filled: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.chooseFlowers),
          ),
        ],
      ),
    );
  }
}
