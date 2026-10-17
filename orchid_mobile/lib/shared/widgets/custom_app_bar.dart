import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

/// Reusable application top bar widget with flexible leading, title, and trailing actions.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? titleColor;
  final String? titleFontFamily;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final Widget? centerWidget;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.titleFontSize,
    this.titleFontWeight,
    this.titleColor,
    this.titleFontFamily,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.centerWidget,
  });

  /// Factory for the standard Orchid app bar with back button, centered title, and trailing actions.
  factory CustomAppBar.orchid({
    Key? key,
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    Widget? centerWidget,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      titleFontSize: 24.sp,
      titleFontWeight: FontWeight.w400,
      titleColor: AppColors.black,
      titleFontFamily: AppFonts.goudyOldStyle,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 0),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerWidget: centerWidget,
    );
  }

  /// Factory for app bar with only back button and title (no trailing actions).
  factory CustomAppBar.backOnly({
    Key? key,
    required String title,
    VoidCallback? onBackPressed,
    Widget? centerWidget,
  }) {
    return CustomAppBar.orchid(
      key: key,
      title: title,
      actions: null,
      onBackPressed: onBackPressed,
      centerWidget: centerWidget,
    );
  }

  /// Factory for app bar with back button, title, and single trailing action.
  factory CustomAppBar.withAction({
    Key? key,
    required String title,
    required Widget action,
    VoidCallback? onBackPressed,
    Widget? centerWidget,
  }) {
    return CustomAppBar.orchid(
      key: key,
      title: title,
      actions: [action],
      onBackPressed: onBackPressed,
      centerWidget: centerWidget,
    );
  }

  /// Factory for app bar with back button, title, and two trailing actions.
  factory CustomAppBar.withTwoActions({
    Key? key,
    required String title,
    required Widget action1,
    required Widget action2,
    VoidCallback? onBackPressed,
    Widget? centerWidget,
  }) {
    return CustomAppBar.orchid(
      key: key,
      title: title,
      actions: [action1, action2],
      onBackPressed: onBackPressed,
      centerWidget: centerWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLeading = leading ??
        (showBackButton && Navigator.canPop(context)
            ? _buildDefaultBackButton(context)
            : null);

    final effectiveActions = actions != null && actions!.isNotEmpty
        ? _buildActionsRow()
        : null;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (effectiveLeading != null)
            Align(
              alignment: Alignment.centerLeft,
              child: effectiveLeading,
            ),
          if (centerWidget != null)
            Align(alignment: Alignment.center, child: centerWidget!)
          else
            Align(
              alignment: Alignment.center,
              child: CustomText(
                text: title,
                fontFamily: titleFontFamily ?? AppFonts.goudyOldStyle,
                fontSize: titleFontSize ?? 24.sp,
                fontWeight: titleFontWeight ?? FontWeight.w400,
                textColor: titleColor ?? AppColors.black,
              ),
            ),
          if (effectiveActions != null)
            Align(
              alignment: Alignment.centerRight,
              child: effectiveActions,
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultBackButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: SizedBox(
        width: 24.r,
        height: 24.r,
        child: Image.asset(
          AppAssets.backButtonIcon,
          fit: BoxFit.contain,
        ),
      ),
      onPressed: onBackPressed ?? () => Navigator.maybePop(context),
    );
  }

  Widget _buildActionsRow() {
    // Define how much to shift the icons to bring them together
    double cartShift = 7.0.w;  // Shift cart right
    double favShift = 2.0.w;   // Shift favorite left

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!.asMap().entries.map((entry) {
        int index = entry.key;
        Widget action = entry.value;

        // For the FIRST icon (cart): Shift it RIGHT so the row width is physically smaller.
        // This forces Alignment.centerRight to pin the cart to the actual right edge.
        if (index == 0) {
          return Transform.translate(
            offset: Offset(cartShift, 0),
            child: action,
          );
        }

        // For the SECOND icon (favorite): Shift it LEFT to bring it near the cart.
        return Transform.translate(
          offset: Offset(-favShift, 0),
          child: action,
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (padding?.vertical ?? 0));
}

/// Convenience widget for creating standard trailing action buttons.
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;
  final double? iconSize;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: SizedBox(
        width: (size ?? 24).r,
        height: (size ?? 24).r,
        child: Icon(icon, color: color ?? AppColors.black, size: iconSize ?? 20),
      ),
      onPressed: onPressed,
    );
  }
}