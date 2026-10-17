import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';

/// Desktop-first building blocks for the Inspiration page.
///
/// These only own presentation: the colors, copy and content mirror the mobile
/// screen exactly. Sizing uses fixed logical pixels (not `flutter_screenutil`)
/// because on the web the app pins the design size, so these values render 1:1
/// on any monitor — the same convention as the other web pages.

/// Desktop inspiration card: a wide tile with the bouquet photo on the left and
/// the creator + ingredient list on the right, matching the mobile card copy.
class WebInspirationCard extends StatefulWidget {
  final String username;
  final String imagePath;
  final List<String> ingredients;
  final VoidCallback onChoose;

  const WebInspirationCard({
    super.key,
    required this.username,
    required this.imagePath,
    required this.ingredients,
    required this.onChoose,
  });

  @override
  State<WebInspirationCard> createState() => _WebInspirationCardState();
}

class _WebInspirationCardState extends State<WebInspirationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppColors.cardBorder
                : AppColors.cardBorder.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
              blurRadius: _hovered ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 210,
              child: ColoredBox(
                color: AppColors.background,
                child: SkeletonImage(
                  path: widget.imagePath,
                  fit: BoxFit.contain,
                  errorWidget: const SkeletonFallbackBox(
                    color: AppColors.fieldPink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              AssetImage(AppAssets.placeholderProfile),
                          backgroundColor: AppColors.fieldPink,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomText(
                            text: 'created by @${widget.username}',
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.darkGreen,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 34),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: widget.ingredients.length,
                          separatorBuilder: (context, _) =>
                              const SizedBox(height: 4),
                          itemBuilder: (context, index) => CustomText(
                            text: widget.ingredients[index],
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 14,
                            textColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _ChooseButton(
                        hovered: _hovered,
                        onTap: widget.onChoose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChooseButton extends StatelessWidget {
  final bool hovered;
  final VoidCallback onTap;

  const _ChooseButton({required this.hovered, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: hovered ? AppColors.primary : AppColors.cardBorder,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const CustomText(
            text: 'choose this bouquet >',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            textColor: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// Centered loading / error / empty message for the desktop inspiration grid.
class WebInspirationMessage extends StatelessWidget {
  final String message;
  final bool showLoader;
  final VoidCallback? onRetry;

  const WebInspirationMessage({
    super.key,
    required this.message,
    this.showLoader = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLoader) ...[
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
            ],
            CustomText(
              text: message,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 18,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onRetry,
                child: const CustomText(
                  text: 'try again',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
