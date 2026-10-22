import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';
import 'web_account_widgets.dart';

/// Desktop-first "about app" page (>= 768px). Same colors, copy and content
/// as the mobile screen — only the layout differs.
class AboutWebView extends StatelessWidget {
  final Animation<double> Function(int index) animationFor;
  final SlideDirection direction;
  final double slideDistance;

  const AboutWebView({
    super.key,
    required this.animationFor,
    required this.direction,
    required this.slideDistance,
  });

  Widget _slide(int index, Widget child) => FadeSlideIn(
    animation: animationFor(index),
    direction: direction,
    distance: slideDistance,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return AccountWebScaffold(
      title: 'about app',
      titleAnimation: animationFor(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _slide(1, const Center(child: WebOrchidBrand())),
          const SizedBox(height: 12),
          _slide(
            2,
            const Text(
              'a special flower shop app made with\nlove for flower lovers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _slide(
            3,
            const AccountWebCardGrid(
              children: [
                WebAboutInfoRow(
                  iconAsset: AppAssets.appNameIcon,
                  label: 'App Name',
                  value: 'ORCHID',
                ),
                WebAboutInfoRow(
                  iconAsset: AppAssets.versionIcon,
                  label: 'Version',
                  value: '1.0.0',
                ),
                WebAboutInfoRow(
                  iconAsset: AppAssets.lastUpdatedIcon,
                  label: 'Last Updated',
                  value: 'Sep 2026',
                ),
                WebAboutInfoRow(
                  iconAsset: AppAssets.developerIcon,
                  label: 'Developer',
                  value: 'ORCHID team',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _slide(4, const WebAboutFooter()),
          const SizedBox(height: 24),
          _slide(
            5,
            Center(
              child: Image.asset(
                AppAssets.coloredFlowerIcon,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
