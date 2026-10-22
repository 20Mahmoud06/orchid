import 'package:flutter/material.dart';
import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/home/view/widgets/web/web_pill_button.dart';

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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left text & button
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Build a bouquet that feels like you',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.storeDeepGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your favorite flowers, add a personal touch,\nand create something truly special.',
                    style: TextStyle(
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.storeBodyText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  WebPillButton(
                    label: 'Start creating  →',
                    filled: true,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.chooseFlowers),
                  ),
                ],
              ),
            ),
          ),

          // Right floral graphic (pink tulips from buildFlower.jpg)
          Expanded(
            flex: 5,
            child: Image.asset(
              AppAssets.buildFlower,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build a bouquet that feels like you',
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.storeDeepGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your favorite flowers, add a personal touch, and create something truly special.',
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 13,
              height: 1.35,
              color: AppColors.storeBodyText,
            ),
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
