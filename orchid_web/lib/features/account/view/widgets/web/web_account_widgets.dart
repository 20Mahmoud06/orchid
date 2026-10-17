import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';

/// Desktop-first building blocks for the static account pages
/// (About App, Privacy Policy, Terms & Conditions).
///
/// These only own presentation: the colors, copy and content mirror the mobile
/// screens exactly. Sizing uses fixed logical pixels (not `flutter_screenutil`)
/// because on the web the app pins the design size, so these values render 1:1
/// on any monitor — the same convention as the other web pages.

/// Centered, scrollable shell for a static content page: a page title followed
/// by the [child] inside a comfortable, desktop-friendly reading column.
///
/// When [titleAnimation] is provided the page title eases in with the same
/// fade/slide entrance used by the rest of the content.
class AccountWebScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxWidth;
  final Animation<double>? titleAnimation;
  final SlideDirection titleDirection;
  final double titleDistance;

  const AccountWebScaffold({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 900,
    this.titleAnimation,
    this.titleDirection = SlideDirection.leftToRight,
    this.titleDistance = 14,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 34,
        height: 1.1,
        color: AppColors.darkGreen,
      ),
    );

    if (titleAnimation != null) {
      titleWidget = FadeSlideIn(
        animation: titleAnimation!,
        direction: titleDirection,
        distance: titleDistance,
        child: titleWidget,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleWidget,
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out content cards in a responsive grid: two columns on wide screens,
/// a single stacked column on narrower ones. An odd last card spans the width.
class AccountWebCardGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  const AccountWebCardGrid({
    super.key,
    required this.children,
    this.spacing = 20,
    this.breakpoint = 640,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          final stacked = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            if (i > 0) stacked.add(SizedBox(height: spacing));
            stacked.add(children[i]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: stacked,
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final hasRight = i + 1 < children.length;
          final isLast = i + 2 >= children.length;
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[i]),
                  if (hasRight) ...[
                    SizedBox(width: spacing),
                    Expanded(child: children[i + 1]),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/// ORCHID flower + wordmark used at the top of the About page.
class WebOrchidBrand extends StatelessWidget {
  const WebOrchidBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.smallFlowerSplash,
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 2),
        const Text(
          'ORCHID',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 42,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: -0.84,
            color: AppColors.darkGreen,
            shadows: [
              Shadow(
                offset: Offset(4, 4),
                blurRadius: 7,
                color: Color(0x40000000),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'flower shop',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyBookletter,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: -0.36,
            color: AppColors.flowerShopGreen,
            shadows: [
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Color(0x40000000),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-width "label : value" info row (About page).
class WebAboutInfoRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const WebAboutInfoRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.sideBarIcons,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + title + body card (Privacy and Terms pages).
class WebPrivacyInfoCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String body;

  const WebPrivacyInfoCard({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconAsset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sideBarIcons,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft blush heading panel with a title and supporting sentence.
class WebAccountHeaderCard extends StatelessWidget {
  final String title;
  final String body;

  const WebAccountHeaderCard({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Closing message card (Privacy and Terms pages): a flower, a titled divider
/// row and a heart.
class WebAccountFooter extends StatelessWidget {
  final String title;
  final String description;

  const WebAccountFooter({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.smallFlowerSplash,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(text: title, style: titleStyle),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();
                final titleWidth =
                    textPainter.width.clamp(0.0, constraints.maxWidth);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: titleStyle.copyWith(
                        color: AppColors.thanksYouText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: titleWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Divider(
                              color: AppColors.thanksYouText,
                              thickness: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontFamily: AppFonts.goudyOldStyle,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Divider(
                              color: AppColors.thanksYouText,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      AppAssets.heartIcon,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "More than flowers / It is a feeling" closing card (About page).
class WebAboutFooter extends StatelessWidget {
  const WebAboutFooter({super.key});

  @override
  Widget build(BuildContext context) {
    const titleText = 'More than flowers';
    const titleStyle = TextStyle(
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.privacyBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: const TextSpan(text: titleText, style: titleStyle),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout();
              final titleWidth =
                  textPainter.width.clamp(0.0, constraints.maxWidth);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: titleStyle.copyWith(color: AppColors.thanksYouText),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: titleWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.thanksYouText,
                            thickness: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'It is a feeling',
                          style: TextStyle(
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Divider(
                            color: AppColors.thanksYouText,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppAssets.heartIcon,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          right: -8,
          top: 35,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              AppAssets.bigFlowerSplash,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
