import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

/// Generic reusable button for Orchid application with ScreenUtil responsiveness.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? icon;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontFamily = AppFonts.inriaSerif,
    this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.icon,
    this.borderRadius,
    this.border,
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = height ?? 56.h;
    final double buttonFontSize = fontSize ?? 24.sp;
    final BorderRadius defaultRadius =
        borderRadius ?? BorderRadius.circular(10.r);

    return Container(
      width: width ?? double.infinity,
      height: buttonHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.buttonPink,
        borderRadius: defaultRadius,
        border: border,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                offset: Offset(0, 4.h),
                blurRadius: 8.r,
                spreadRadius: 0,
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: defaultRadius,
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 22.r,
                    width: 22.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.darkGreen,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                      Flexible(
                        child: CustomText(
                          text: label,
                          fontFamily: fontFamily,
                          fontSize: buttonFontSize,
                          fontWeight: fontWeight,
                          textColor: textColor ?? AppColors.darkGreen,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
