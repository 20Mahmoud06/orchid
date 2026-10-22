import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../features/payment/widgets/radio_indicator.dart';
import 'custom_text.dart';

/// Radio-style option card for the add message screen with subtle selection animation.
class MessageOptionCard extends StatefulWidget {
  final String? iconPath;
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool isSelected;
  final bool isEnabledStyle;
  final VoidCallback onTap;

  const MessageOptionCard({
    super.key,
    this.iconPath,
    this.icon,
    this.customIcon,
    required this.label,
    required this.isSelected,
    this.isEnabledStyle = true,
    required this.onTap,
  }) : assert(
         iconPath != null || icon != null || customIcon != null,
         'Either iconPath, icon, or customIcon must be provided',
       );

  @override
  State<MessageOptionCard> createState() => _MessageOptionCardState();
}

class _MessageOptionCardState extends State<MessageOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _borderWidthAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Border color animation - smooth transition
    _borderColorAnimation =
        ColorTween(
          begin: AppColors.incrementButton,
          end: AppColors.selectedCategory,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Border width animation - subtle change
    _borderWidthAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // If initially selected, start with animation completed
    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MessageOptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isSelected && widget.isEnabledStyle;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final borderColor = widget.isSelected
            ? (_borderColorAnimation.value ?? AppColors.selectedCategory)
            : AppColors.incrementButton;

        final borderWidth = widget.isSelected
            ? (_borderWidthAnimation.value)
            : 1.0.w;

        return GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.selectedCategory.withValues(
                          alpha: 0.08,
                        ),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.customIcon != null)
                  widget.customIcon!
                else if (widget.iconPath != null)
                  Image.asset(
                    widget.iconPath!,
                    width: 28.r,
                    height: 28.r,
                    fit: BoxFit.contain,
                    color: isActive ? AppColors.black : AppColors.iconColor,
                  )
                else
                  Icon(
                    widget.icon,
                    size: 24.r,
                    color: isActive ? AppColors.black : AppColors.iconColor,
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomText(
                    text: widget.label,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
                    textColor: isActive
                        ? AppColors.black
                        : AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
                RadioIndicator(
                  isSelected: widget.isSelected,
                  scaleAnimation: _animationController.drive(
                    Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: Curves.easeOutBack)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
