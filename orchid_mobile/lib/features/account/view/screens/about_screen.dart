import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../widgets/about_footer.dart';
import '../widgets/about_info_row.dart';

class AboutScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const AboutScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// 9 items: appbar, brand, tagline, 4 info rows, footer, flower icon.
  static const int _itemCount = 9;

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
                  title: 'about app',
                  onBackPressed: widget.onBackPressed,
                ),
              ),
              SizedBox(height: 16.h),

              FadeSlideIn(
                animation: _animFor(1),
                direction: _direction,
                distance: _slideDistance,
                child: OrchidBrandWidget(
                  showShadow: true,
                  flowerSize: 100.r,
                  orchidFontSize: 42.sp,
                  flowerShopFontSize: 18.sp,
                  spacing: 2.h,
                ),
              ),
              SizedBox(height: 12.h),

              FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: CustomText(
                  text:
                  'a special flower shop app made with\nlove for flower lovers.',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.darkGreen,
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),

              FadeSlideIn(
                animation: _animFor(3),
                direction: _direction,
                distance: _slideDistance,
                child: AboutInfoRow(
                  iconAsset: AppAssets.appNameIcon,
                  label: 'App Name',
                  value: 'ORCHID',
                ),
              ),
              SizedBox(height: 12.h),

              FadeSlideIn(
                animation: _animFor(4),
                direction: _direction,
                distance: _slideDistance,
                child: AboutInfoRow(
                  iconAsset: AppAssets.versionIcon,
                  label: 'Version',
                  value: '1.0.0',
                ),
              ),
              SizedBox(height: 12.h),

              FadeSlideIn(
                animation: _animFor(5),
                direction: _direction,
                distance: _slideDistance,
                child: AboutInfoRow(
                  iconAsset: AppAssets.lastUpdatedIcon,
                  label: 'Last Updated',
                  value: 'Sep 2026',
                ),
              ),
              SizedBox(height: 12.h),

              FadeSlideIn(
                animation: _animFor(6),
                direction: _direction,
                distance: _slideDistance,
                child: AboutInfoRow(
                  iconAsset: AppAssets.developerIcon,
                  label: 'Developer',
                  value: 'ORCHID team',
                ),
              ),
              SizedBox(height: 24.h),

              FadeSlideIn(
                animation: _animFor(7),
                direction: _direction,
                distance: _slideDistance,
                child: const AboutFooter(),
              ),
              SizedBox(height: 24.h),

              FadeSlideIn(
                animation: _animFor(8),
                direction: _direction,
                distance: _slideDistance,
                child: Image.asset(
                  AppAssets.coloredFlowerIcon,
                  width: 40.r,
                  height: 40.r,
                  fit: BoxFit.contain,
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