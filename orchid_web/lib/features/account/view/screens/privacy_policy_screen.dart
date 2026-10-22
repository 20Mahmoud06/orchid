import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../widgets/account_footer.dart';
import '../widgets/privacy_header_card.dart';
import '../widgets/privacy_info_card.dart';
import '../widgets/web/privacy_policy_web_view.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const PrivacyPolicyScreen({super.key, this.onBackPressed});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
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
      // ⬅️ Was 900ms — now a calm 2000ms total cascade.
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gentler stagger:
  /// - spread = 0.55 → items start further apart
  /// - window = 0.45 → each item takes ~45% of 2s = ~900ms to fully appear
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
          return PrivacyPolicyWebView(
            animationFor: _animFor,
            direction: _direction,
            slideDistance: _slideDistance,
          );
        }
        return _buildMobile();
      },
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
                  title: 'privacy policy',
                  onBackPressed: widget.onBackPressed,
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(1),
                direction: _direction,
                distance: _slideDistance,
                child: Image.asset(
                  AppAssets.privacy,
                  width: 140.r,
                  height: 140.r,
                  fit: BoxFit.contain,
                ),
              ),

              FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyHeaderCard(),
              ),
              SizedBox(height: 20.h),

              FadeSlideIn(
                animation: _animFor(3),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyInfoCard(
                  iconAsset: AppAssets.infoIcon,
                  title: 'Information We Collect',
                  body:
                      'We collect only the information you provide such as your name, phone number, and delivery address to provide our services and improve your experience.',
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(4),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyInfoCard(
                  iconAsset: AppAssets.yourDataIcon,
                  title: 'How We Use Your Data',
                  body:
                      'Your data is used to process your orders, communicate with you, and send you relevant updates and offers. We do not sell your data to third parties.',
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(5),
                direction: _direction,
                distance: _slideDistance,
                child: const PrivacyInfoCard(
                  iconAsset: AppAssets.yourSecurityIcon,
                  title: 'Your Security',
                  body:
                      'We use industry-standard security measures to protect your information and keep it safe at all times.',
                ),
              ),
              SizedBox(height: 24.h),

              FadeSlideIn(
                animation: _animFor(6),
                direction: _direction,
                distance: _slideDistance,
                child: const AccountFooter(
                  title: 'Thank you for trusting ORCHID',
                  description: 'Your privacy is our priority',
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
