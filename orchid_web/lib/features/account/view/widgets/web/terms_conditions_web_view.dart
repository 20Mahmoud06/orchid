import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';
import 'web_account_widgets.dart';

/// Desktop-first "terms & conditions" page (>= 768px). Same colors, copy and
/// content as the mobile screen — only the layout differs.
class TermsConditionsWebView extends StatelessWidget {
  final Animation<double> Function(int index) animationFor;
  final SlideDirection direction;
  final double slideDistance;

  const TermsConditionsWebView({
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
      title: 'terms & conditions',
      titleAnimation: animationFor(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _slide(
            1,
            Center(
              child: Image.asset(
                AppAssets.terms,
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
              title: 'Terms & Conditions',
              body:
                  'By using our app, you agree to the\nfollowing terms and conditions.',
            ),
          ),
          const SizedBox(height: 20),
          _slide(
            3,
            const AccountWebCardGrid(
              children: [
                WebPrivacyInfoCard(
                  iconAsset: AppAssets.useAppIcon,
                  title: 'Use of the App',
                  body:
                      'You agree to use the app for lawful purposes only and in accordance with these terms. You may not misuse, copy, or distribute any part of the app.',
                ),
                WebPrivacyInfoCard(
                  iconAsset: AppAssets.ordersIcon,
                  title: 'Orders & Payments',
                  body:
                      'All orders are subject to availability and confirmation. Prices, payment methods and delivery times are as shown in the app.',
                ),
                WebPrivacyInfoCard(
                  iconAsset: AppAssets.limitationIcon,
                  title: 'Limitation of Liability',
                  body:
                      'We are not responsible for any indirect, incidental, or consequential damages arising from the use of our app or services.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _slide(
            4,
            const WebAccountFooter(
              title: 'Thank you for being with us',
              description: 'Together we grow',
            ),
          ),
        ],
      ),
    );
  }
}
