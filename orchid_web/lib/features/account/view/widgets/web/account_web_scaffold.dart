import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';
import '../../../../../shared/widgets/custom_text.dart';

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
    Widget titleWidget = CustomText(
      text: title,
      textAlign: TextAlign.center,
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 34,
      height: 1.1,
      textColor: AppColors.darkGreen,
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
                children: [titleWidget, const SizedBox(height: 32), child],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
