import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../widgets/contact_section.dart' show ContactSection;
import '../widgets/contact_section_tile.dart';
import '../widgets/web/web_contact_widgets.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/slider_direction.dart';

class ContactUsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ContactUsScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _itemCount = 8;

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

  Future<void> _launchUrl(String url, {LaunchMode mode = LaunchMode.externalApplication}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: mode)) {
      debugPrint('Could not launch $url');
    }
  }

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

  /// Desktop-first "contact us" page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — only the layout differs: a single
  /// rectangular panel with the brand and follow section on the left and the
  /// contact options on the right, so it fits without a long scroll.
  Widget _buildWeb() {
    final leftColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const WebContactBrand(),
        const SizedBox(height: 20),
        const Text(
          'HOW CAN WE HELP YOU ?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.selectedCategory,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'our team is here to make your\nflower shopping easier.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Follow Us',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.selectedCategory,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'stay in bloom with ORCHID',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WebSocialIcon(asset: AppAssets.facebookIcon),
            SizedBox(width: 32),
            WebSocialIcon(asset: AppAssets.instagramIcon),
            SizedBox(width: 32),
            WebSocialIcon(asset: AppAssets.tiktokIcon),
          ],
        ),
      ],
    );

    final contactSection = WebContactSection(
      tiles: [
        WebContactTile(
          icon: const Icon(
            Ionicons.call,
            size: 22,
            color: AppColors.black,
          ),
          title: 'Call Us',
          subtitle: '+20 110 080 1388',
          onTap: () => _launchUrl('tel:+201100801388'),
        ),
        WebContactTile(
          icon: Image.asset(
            AppAssets.whatsappBlackIcon,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          title: 'Chat With Us',
          subtitle: '+20 110 080 1388',
          onTap: () => _launchUrl('https://wa.me/201100801388'),
        ),
        WebContactTile(
          icon: const Icon(
            Icons.mail_outline,
            size: 22,
            color: AppColors.black,
          ),
          title: 'E-mail',
          subtitle: 'orchidflowershop@gmail.com',
          onTap: () => _launchUrl('mailto:orchidflowershop@gmail.com'),
        ),
        WebContactTile(
          icon: const Icon(
            Ionicons.location,
            size: 22,
            color: AppColors.black,
          ),
          title: 'Our Location',
          subtitle: 'Egypt, Ismailia',
          onTap: () => _launchUrl(
            'https://www.google.com/maps/search/?api=1&query=Ismailia%2C%20Egypt',
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _webSlide(
                    0,
                    const Text(
                      'contact us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 560) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _webSlide(1, leftColumn),
                              const SizedBox(height: 32),
                              _webSlide(2, contactSection),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 4, child: _webSlide(1, leftColumn)),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 5,
                              child: _webSlide(2, contactSection),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                  title: 'contact us',
                  onBackPressed: widget.onBackPressed,
                  centerWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: 'contact us',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.black,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              FadeSlideIn(
                animation: _animFor(1),
                direction: _direction,
                distance: _slideDistance,
                child: OrchidBrandWidget(
                  flowerSize: 120.r,
                  orchidFontSize: 62.sp,
                  flowerShopFontSize: 22.sp,
                  spacing: 4.h,
                ),
              ),
              SizedBox(height: 24.h),
              FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: CustomText(
                  text: 'HOW CAN WE HELP YOU ?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.selectedCategory,
                ),
              ),
              SizedBox(height: 8.h),
              FadeSlideIn(
                animation: _animFor(3),
                direction: _direction,
                distance: _slideDistance,
                child: CustomText(
                  text: 'our team is here to make your\nflower shopping easier.',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.black,
                  textAlign: TextAlign.center,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              FadeSlideIn(
                animation: _animFor(4),
                direction: _direction,
                distance: _slideDistance,
                child: ContactSection(
                  tiles: [
                    ContactSectionTile(
                      icon: Icon(
                        Ionicons.call,
                        size: 22.r,
                        color: AppColors.black,
                      ),
                      title: 'Call Us',
                      subtitle: '+20 110 080 1388',
                      onTap: () => _launchUrl('tel:+201100801388'),
                    ),
                    ContactSectionTile(
                      icon: Image.asset(
                        AppAssets.whatsappBlackIcon,
                        width: 22.r,
                        height: 22.r,
                        fit: BoxFit.contain,
                      ),
                      title: 'Chat With Us',
                      subtitle: '+20 110 080 1388',
                      onTap: () =>
                          _launchUrl('https://wa.me/201100801388'),
                    ),
                    ContactSectionTile(
                      icon: Icon(
                        Icons.mail_outline,
                        size: 22.r,
                        color: AppColors.black,
                      ),
                      title: 'E-mail',
                      subtitle: 'orchidflowershop@gmail.com',
                      onTap: () =>
                          _launchUrl('mailto:orchidflowershop@gmail.com'),
                    ),
                    ContactSectionTile(
                      icon: Icon(
                        Ionicons.location,
                        size: 22.r,
                        color: AppColors.black,
                      ),
                      title: 'Our Location',
                      subtitle: 'Egypt, Ismailia',
                      onTap: () =>
                          _launchUrl('https://www.google.com/maps/search/?api=1&query=Ismailia%2C%20Egypt'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              FadeSlideIn(
                animation: _animFor(5),
                direction: _direction,
                distance: _slideDistance,
                child: CustomText(
                  text: 'Follow Us',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.selectedCategory,
                ),
              ),
              SizedBox(height: 6.h),
              FadeSlideIn(
                animation: _animFor(6),
                direction: _direction,
                distance: _slideDistance,
                child: CustomText(
                  text: 'stay in bloom with ORCHID',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.black,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20.h),
              FadeSlideIn(
                animation: _animFor(7),
                direction: _direction,
                distance: _slideDistance,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialIcon(asset: AppAssets.facebookIcon),
                    SizedBox(width: 24.w),
                    _SocialIcon(asset: AppAssets.instagramIcon),
                    SizedBox(width: 24.w),
                    _SocialIcon(asset: AppAssets.tiktokIcon),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;

  const _SocialIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 52.r,
      height: 52.r,
      fit: BoxFit.contain,
    );
  }
}
