import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../../../../shared/widgets/slider_direction.dart';
import 'contact_section.dart' show ContactSection;
import 'contact_section_tile.dart';

/// Mobile layout of the contact screen (unchanged presentation).
class ContactUsMobileView extends StatelessWidget {
  static const SlideDirection _direction = SlideDirection.leftToRight;
  static const double _slideDistance = 14;

  final VoidCallback? onBackPressed;
  final Animation<double> Function(int index) animationFor;
  final Future<void> Function(String url) onLaunchUrl;

  const ContactUsMobileView({
    super.key,
    required this.onBackPressed,
    required this.animationFor,
    required this.onLaunchUrl,
  });

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
                animation: animationFor(0),
                direction: _direction,
                distance: _slideDistance,
                child: CustomAppBar.orchid(
                  title: 'contact us',
                  onBackPressed: onBackPressed,
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
                animation: animationFor(1),
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
                animation: animationFor(2),
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
                animation: animationFor(3),
                direction: _direction,
                distance: _slideDistance,
                child: CustomText(
                  text:
                      'our team is here to make your\nflower shopping easier.',
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
                animation: animationFor(4),
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
                      onTap: () => onLaunchUrl('tel:+201100801388'),
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
                      onTap: () => onLaunchUrl('https://wa.me/201100801388'),
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
                          onLaunchUrl('mailto:orchidflowershop@gmail.com'),
                    ),
                    ContactSectionTile(
                      icon: Icon(
                        Ionicons.location,
                        size: 22.r,
                        color: AppColors.black,
                      ),
                      title: 'Our Location',
                      subtitle: 'Egypt, Ismailia',
                      onTap: () => onLaunchUrl(
                        'https://www.google.com/maps/search/?api=1&query=Ismailia%2C%20Egypt',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              FadeSlideIn(
                animation: animationFor(5),
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
                animation: animationFor(6),
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
                animation: animationFor(7),
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
    return Image.asset(asset, width: 52.r, height: 52.r, fit: BoxFit.contain);
  }
}
