import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import '../../../models/flower_item.dart';

/// Desktop-first building blocks for the Choose Flowers page.
///
/// These only own presentation: the colors, copy and behaviour mirror the
/// mobile screen exactly. Sizing uses fixed logical pixels (not
/// `flutter_screenutil`) because on the web the app pins the design size, so
/// these values render 1:1 on any monitor — the same convention as the other
/// web pages.

/// Fixed-size search field matching the mobile "Search for flowers" bar.
class WebFlowerSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const WebFlowerSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search for flowers',
  });

  @override
  State<WebFlowerSearchBar> createState() => _WebFlowerSearchBarState();
}

class _WebFlowerSearchBarState extends State<WebFlowerSearchBar> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateHasText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _hasText = _controller.text.isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_updateHasText);
    }
    super.dispose();
  }

  void _updateHasText() {
    if (mounted) {
      setState(() => _hasText = _controller.text.isNotEmpty);
    }
  }

  void _clearText() {
    _controller.clear();
    setState(() => _hasText = false);
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: focused ? AppColors.selectedCategory : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: focused
                ? AppColors.darkGreen.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: focused ? 8 : 4,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (value) {
          setState(() => _hasText = value.isNotEmpty);
          widget.onChanged?.call(value);
        },
        style: const TextStyle(
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16,
            color: AppColors.iconColor.withValues(alpha: focused ? 0.9 : 0.7),
          ),
          prefixIcon: Icon(
            Ionicons.search_outline,
            size: 21,
            color: focused ? AppColors.darkGreen : AppColors.iconColor,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _clearText,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// Desktop category tab strip mirroring the mobile `FlowerCategoryTabs`.
class WebFlowerCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const WebFlowerCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 35),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = categories[index];
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.selectedCategory
                              : AppColors.black,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: CustomText(
                          text: label,
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16,
                          textColor: isSelected
                              ? AppColors.selectedCategory
                              : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        height: 2.5,
                        width: isSelected ? _textWidth(label) : 0,
                        decoration: BoxDecoration(
                          color: AppColors.selectedCategory,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _textWidth(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width + 12;
  }
}

/// Desktop flower card: white tile with cover image, heart toggle, name, price
/// and the same quantity stepper as the mobile grid card.
class WebFlowerGridCard extends StatelessWidget {
  final FlowerItem flower;
  final bool isFavorite;
  final int quantity;
  final bool showQuantityControl;
  final Color? favoriteHeartColor;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const WebFlowerGridCard({
    super.key,
    required this.flower,
    required this.isFavorite,
    required this.quantity,
    this.showQuantityControl = true,
    this.favoriteHeartColor,
    required this.onFavoriteToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SkeletonImage(
                    path: flower.imagePath,
                    fit: BoxFit.cover,
                    placeholderColor: AppColors.fieldPink,
                    errorWidget: const SkeletonFallbackBox(
                      color: AppColors.fieldPink,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFavoriteToggle,
                      child: Icon(
                        isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                        size: 18,
                        color: isFavorite
                            ? (favoriteHeartColor ?? AppColors.redText)
                            : AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: flower.name,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15,
                  textColor: AppColors.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: '${flower.price} EGP',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 14,
                        textColor: AppColors.black.withValues(alpha: 0.7),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showQuantityControl) ...[
                      const SizedBox(width: 6),
                      _WebQuantityControl(
                        quantity: quantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebQuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _WebQuantityControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.incrementButton,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 18, color: AppColors.white),
          ),
        ),
      );
    }

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDecrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.remove, size: 15, color: AppColors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CustomText(
              text: '$quantity',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              textColor: AppColors.white,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onIncrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.add, size: 15, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered loading / error / empty message for the desktop flower grid.
class WebFlowerCatalogMessage extends StatelessWidget {
  final String message;
  final bool showLoader;
  final VoidCallback? onRetry;

  const WebFlowerCatalogMessage({
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

/// Full-width floating "view bouquet" bar matching the mobile wording.
class WebViewBouquetBar extends StatelessWidget {
  final int totalCount;
  final int totalPrice;
  final VoidCallback? onTap;

  const WebViewBouquetBar({
    super.key,
    required this.totalCount,
    required this.totalPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.incrementButton,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.designFieldPink.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'view bouquet ($totalCount) >',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textColor: AppColors.viewBouquetButton,
              ),
              CustomText(
                text: '$totalPrice EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                textColor: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
