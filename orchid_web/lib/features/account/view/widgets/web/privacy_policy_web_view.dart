import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';
import 'web_account_widgets.dart';

/// Desktop-first "privacy policy" page (>= 768px). Same colors, copy and
/// content as the mobile screen — only the layout differs.
class PrivacyPolicyWebView extends StatelessWidget {
  final Animation<double> Function(int index) animationFor;
  final SlideDirection direction;
  final double slideDistance;

  const PrivacyPolicyWebView({
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
      title: 'privacy policy',
      titleAnimation: animationFor(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _slide(
            1,
            Center(
              child: Image.asset(
                AppAssets.privacy,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _slide(
            2,
            const WebAccountHeaderCard(
              title: 'Your Privacy Matters',
              body:
                  'We care about how your information\nis collected, used and protected.',
            ),
          ),
          const SizedBox(height: 20),
          _slide(
            3,
            const AccountWebCardGrid(
              children: [
                WebPrivacyInfoCard(
                  iconAsset: AppAssets.infoIcon,
                  title: 'Information We Collect',
                  body:
                      'We collect only the information you provide such as your name, phone number, and delivery address to provide our services and improve your experience.',
                ),
                WebPrivacyInfoCard(
                  iconAsset: AppAssets.yourDataIcon,
                  title: 'How We Use Your Data',
                  body:
                      'Your data is used to process your orders, communicate with you, and send you relevant updates and offers. We do not sell your data to third parties.',
                ),
                WebPrivacyInfoCard(
                  iconAsset: AppAssets.yourSecurityIcon,
                  title: 'Your Security',
                  body:
                      'We use industry-standard security measures to protect your information and keep it safe at all times.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _slide(
            4,
            const WebAccountFooter(
              title: 'Thank you for trusting ORCHID',
              description: 'Your privacy is our priority',
            ),
          ),
        ],
      ),
    );
  }
}
