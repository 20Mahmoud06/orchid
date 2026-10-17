import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

/// Generic reusable custom text field widget matching Orchid soft-pink container design with screenutil responsiveness.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final Color? textColor;
  final Color? containerColor;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final List<BoxShadow>? boxShadow;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.textColor,
    this.containerColor,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.boxShadow,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _borderWidthAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _borderColorAnimation = ColorTween(
      begin: AppColors.cardBorder,
      end: AppColors.selectedCategory,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Border width animation
    _borderWidthAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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

  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius ?? 16.r;

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
      borderSide: BorderSide(
        color: AppColors.selectedCategory,
        width: 2.0.w,
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          initialValue: widget.controller == null ? widget.initialValue : null,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            fontSize: 15.sp,
            color: widget.textColor ?? AppColors.textSecondary,
            fontFamily: AppFonts.goudyOldStyle,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _isFocused
                  ? AppColors.selectedCategory
                  : AppColors.darkGreen.withValues(alpha: 0.7),
              fontSize: 14.sp,
              fontFamily: AppFonts.goudyOldStyle,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.darkGreen.withValues(
                alpha: _isFocused ? 0.6 : 0.45,
              ),
              fontSize: 15.sp,
              fontFamily: AppFonts.goudyOldStyle,
            ),
            filled: true,
            fillColor: widget.fillColor ?? AppColors.fieldBackground,

            border: outlineInputBorder,
            enabledBorder: outlineInputBorder,
            focusedBorder: focusedOutlineInputBorder,
            errorBorder: outlineInputBorder.copyWith(
              borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
            ),
            focusedErrorBorder: focusedOutlineInputBorder.copyWith(
              borderSide: BorderSide(color: AppColors.error, width: 2.0.w),
            ),

            prefixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              minHeight: 48.h,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: widget.prefixIcon,
            )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _isFocused
                    ? AppColors.selectedCategory
                    : AppColors.iconColor,
                size: 22.r,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : widget.suffixIcon,
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        );
      },
    );
  }
}