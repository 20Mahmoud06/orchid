import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../widgets/account_footer.dart';
import '../widgets/privacy_info_card.dart';
import '../widgets/terms_header_card.dart';
import '../widgets/web/web_account_widgets.dart';

class TermsConditionsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const TermsConditionsScreen({super.key, this.onBackPressed});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const int _itemCount = 7;

  /// Small, consistent travel distance for every item.
  static const double _slideDistance = 14;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gentler stagger — same as PrivacyPolicyScreen.
  Animation<double> _animFor(int index) {
    final start = (index / _itemCount) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  static const SlideDirection _direction = SlideDirection.leftToRight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): the same content laid out
        // in a centered reading column. Narrow viewports keep the untouched
        // Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb();
        }
        return _buildMobile();
      },
    );
  }

  /// Entrance helper mirroring the mobile stagger for a single web section.
  Widget _webSlide(int index, Widget child) => FadeSlideIn(
    animation: _animFor(index),
    direction: _direction,
    distance: _slideDistance,
    child: child,
  );

  /// Desktop-first "terms & conditions" page (>= 768px). Same colors, copy and
  /// content as the mobile screen — only the layout differs.
  Widget _buildWeb() {
    return AccountWebScaffold(
      title: 'terms & conditions',
      titleAnimation: _animFor(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _webSlide(
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
          _webSlide(
            2,
            const WebAccountHeaderCard(
              title: 'Terms & Conditions',
              body:
                  'By using our app, you agree to the\nfollowing terms and conditions.',
            ),
          ),
          const SizedBox(height: 20),
          _webSlide(
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
          _webSlide(
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

  /// Mobile layout (unchanged).
  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeSlideIn(
                animation: _animFor(0),
                direction: _direction,
                distance: _slideDistance,
                child: CustomAppBar.orchid(
                  title: 'terms & conditions',
                  onBackPressed: widget.onBackPressed,
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(1),
                direction: _direction,
                distance: _slideDistance,
                child: Image.asset(
                  AppAssets.terms,
                  width: 140.r,
                  height: 140.r,
                  fit: BoxFit.contain,
                ),
              ),

              FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: const TermsHeaderCard(),
              ),
              SizedBox(height: 20.h),

              FadeSlideIn(
                animation: _animFor(3),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyInfoCard(
                  iconAsset: AppAssets.useAppIcon,
                  title: 'Use of the App',
                  body:
                      'You agree to use the app for lawful purposes only and in accordance with these terms. You may not misuse, copy, or distribute any part of the app.',
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(4),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyInfoCard(
                  iconAsset: AppAssets.ordersIcon,
                  title: 'Orders & Payments',
                  body:
                      'All orders are subject to availability and confirmation. Prices, payment methods and delivery times are as shown in the app.',
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(5),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyInfoCard(
                  iconAsset: AppAssets.limitationIcon,
                  title: 'Limitation of Liability',
                  body:
                      'We are not responsible for any indirect, incidental, or consequential damages arising from the use of our app or services.',
                ),
              ),
              SizedBox(height: 24.h),

              FadeSlideIn(
                animation: _animFor(6),
                direction: _direction,
                distance: _slideDistance,
                child: const AccountFooter(
                  title: 'Thank you for being with us',
                  description: 'Together we grow',
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
