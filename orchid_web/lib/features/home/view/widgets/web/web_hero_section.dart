import 'package:flutter/material.dart';
import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/home/view/widgets/web/web_pill_button.dart';

/// Large Hero section with soft blush pink card, balanced 2-column layout,
/// prominent headline, supporting description, two CTA buttons, and floral imagery.
class WebHeroSection extends StatelessWidget {
  const WebHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.storeBlush,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.storeBlushBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: isCompact ? _buildCompact(context) : _buildWide(context),
        );
      },
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Text & Buttons
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 44, 24, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FLOWERS FOR EVERY MOMENT',
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.storeEyebrow,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Make someone’s\nday bloom.',
                  style: TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 44,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.storeDeepGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fresh flowers, thoughtful bouquets, and little\nmoments of happiness — delivered to their door.',
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.storeBodyText,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WebPillButton(
                      label: 'Shop flowers  →',
                      filled: true,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.chooseFlowers),
                    ),
                    const SizedBox(width: 14),
                    WebPillButton(
                      label: 'Build a bouquet  →',
                      filled: false,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.chooseFlowers),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right Column: Bouquet Image
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 380,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                AppAssets.bouquetTest,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FLOWERS FOR EVERY MOMENT',
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.storeEyebrow,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Make someone’s day bloom.',
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: AppColors.storeDeepGreen,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fresh flowers, thoughtful bouquets, and little moments of happiness — delivered to their door.',
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              height: 1.4,
              color: AppColors.storeBodyText,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 220,
              child: Image.asset(AppAssets.bouquetTest, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              WebPillButton(
                label: 'Shop flowers  →',
                filled: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.chooseFlowers),
              ),
              WebPillButton(
                label: 'Build a bouquet  →',
                filled: false,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.chooseFlowers),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
