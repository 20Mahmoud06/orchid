import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';
import 'web_contact_widgets.dart';

/// Desktop-first "contact us" page (>= 768px): brand and follow section on
/// the left, contact options on the right.
class ContactUsWebView extends StatelessWidget {
  static const SlideDirection _direction = SlideDirection.leftToRight;
  static const double _slideDistance = 14;

  final Animation<double> Function(int index) animationFor;
  final Future<void> Function(String url) onLaunchUrl;

  const ContactUsWebView({
    super.key,
    required this.animationFor,
    required this.onLaunchUrl,
  });

  Widget _webSlide(int index, Widget child) => FadeSlideIn(
    animation: animationFor(index),
    direction: _direction,
    distance: _slideDistance,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Ionicons.call, size: 22, color: AppColors.black),
          title: 'Call Us',
          subtitle: '+20 110 080 1388',
          onTap: () => onLaunchUrl('tel:+201100801388'),
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
          onTap: () => onLaunchUrl('https://wa.me/201100801388'),
        ),
        WebContactTile(
          icon: const Icon(
            Icons.mail_outline,
            size: 22,
            color: AppColors.black,
          ),
          title: 'E-mail',
          subtitle: 'orchidflowershop@gmail.com',
          onTap: () => onLaunchUrl('mailto:orchidflowershop@gmail.com'),
        ),
        WebContactTile(
          icon: const Icon(Ionicons.location, size: 22, color: AppColors.black),
          title: 'Our Location',
          subtitle: 'Egypt, Ismailia',
          onTap: () => onLaunchUrl(
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
}
