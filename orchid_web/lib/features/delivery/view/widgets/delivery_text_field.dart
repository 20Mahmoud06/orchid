import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

/// Delivery form text field with animations and support for various icon types.
class DeliveryTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final dynamic
  suffixIcon; // Can be IconData, String (asset path), or Widget (Icon, Image, etc.)
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  final bool readOnly;
  final Color? textColor;
  final Color? fillColor;
  final Color? hintColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final String? labelText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final double? height;
  final int? maxLength;

  const DeliveryTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.readOnly = false,
    this.textColor,
    this.fillColor,
    this.hintColor,
    this.borderRadius,
    this.contentPadding,
    this.labelText,
    this.validator,
    this.inputFormatters,
    this.height,
    this.maxLength,
  });

  @override
  State<DeliveryTextField> createState() => _DeliveryTextFieldState();
}

class _DeliveryTextFieldState extends State<DeliveryTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _borderWidthAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _borderColorAnimation =
        ColorTween(
          begin: AppColors.cardBorder,
          end: AppColors.selectedCategory,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _borderWidthAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _isFocused = true);
        _animationController.forward();
      } else {
        setState(() => _isFocused = false);
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Helper to build suffix icon widget
  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon == null) return null;

    // Case 1: It's already a Widget (like Icon, Image.asset, SvgPicture, etc.)
    if (widget.suffixIcon is Widget) {
      return Padding(
        padding: EdgeInsets.only(
          right: 8.w,
          top: widget.maxLines > 1 ? 8.h : 0,
        ),
        child: Align(
          alignment: widget.maxLines > 1
              ? Alignment.topCenter
              : Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: widget.suffixIcon,
        ),
      );
    }

    // Case 2: It's IconData - wrap with default Icon
    if (widget.suffixIcon is IconData) {
      return Padding(
        padding: EdgeInsets.only(
          right: 8.w,
          top: widget.maxLines > 1 ? 8.h : 0,
        ),
        child: Align(
          alignment: widget.maxLines > 1
              ? Alignment.topCenter
              : Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: Icon(widget.suffixIcon, size: 22.r, color: AppColors.black),
        ),
      );
    }

    // Case 3: It's String (asset path) - wrap with Image.asset
    if (widget.suffixIcon is String) {
      return Padding(
        padding: EdgeInsets.only(
          right: 8.w,
          top: widget.maxLines > 1 ? 8.h : 0,
        ),
        child: Align(
          alignment: widget.maxLines > 1
              ? Alignment.topCenter
              : Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: Image.asset(
            widget.suffixIcon,
            width: 22.r,
            height: 22.r,
            color: AppColors.black,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius ?? 10.r;

    // Build border based on focus state
    final borderColor = _isFocused
        ? (_borderColorAnimation.value ?? AppColors.selectedCategory)
        : AppColors.cardBorder;

    final borderWidth = _isFocused ? _borderWidthAnimation.value : 1.0.w;

    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );

    final focusedOutlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: AppColors.selectedCategory, width: 2.0.w),
    );

    final textField = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 15.sp,
            color: widget.textColor ?? AppColors.black,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: _isFocused
                  ? AppColors.selectedCategory
                  : AppColors.iconColor.withValues(alpha: 0.7),
              fontSize: 14.sp,
              fontFamily: AppFonts.goudyOldStyle,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 15.sp,
              color: widget.hintColor ?? AppColors.black.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: widget.fillColor ?? AppColors.white,
            contentPadding:
                widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

            // Border configurations
            border: outlineInputBorder,
            enabledBorder: outlineInputBorder,
            focusedBorder: focusedOutlineInputBorder,
            errorBorder: outlineInputBorder.copyWith(
              borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
            ),
            focusedErrorBorder: focusedOutlineInputBorder.copyWith(
              borderSide: BorderSide(color: AppColors.error, width: 2.0.w),
            ),

            // Suffix icon
            suffixIcon: _buildSuffixIcon(),
            suffixIconConstraints: widget.suffixIcon != null
                ? BoxConstraints(
                    minWidth: 40.w,
                    minHeight: widget.maxLines > 1 ? 40.h : 48.h,
                  )
                : null,
          ),
        );
      },
    );

    // 👇 Apply height constraint if provided
    return widget.height != null
        ? SizedBox(height: widget.height, child: textField)
        : textField;
  }
}
