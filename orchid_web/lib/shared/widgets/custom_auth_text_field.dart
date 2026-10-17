import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import 'custom_text.dart';

class CustomAuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final Color? textColor;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;

  const CustomAuthTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.textColor,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.inputFormatters,
  });

  @override
  State<CustomAuthTextField> createState() => _CustomAuthTextFieldState();
}

class _CustomAuthTextFieldState extends State<CustomAuthTextField>
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
      begin: Colors.transparent,
      end: AppColors.incrementButton,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Border width animation
    _borderWidthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
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
    final double radius = widget.borderRadius ?? 10.r;

    // Border color: Transparent when unfocused, incrementButton when focused
    final borderColor = _isFocused
        ? (_borderColorAnimation.value ?? AppColors.incrementButton)
        : Colors.transparent;

    final borderWidth = _isFocused ? _borderWidthAnimation.value : 0.0;

    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );

    final focusedOutlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: AppColors.selectedCategory,
        width: 1.5.w,
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: TextStyle(
              fontSize: 15.sp,
              color: widget.textColor ?? AppColors.textSecondary,
              fontFamily: 'InriaSerif',
            ),
            decoration: InputDecoration(
              label: widget.label != null
                  ? CustomText(
                text: widget.label!,
                textColor: _isFocused
                    ? AppColors.incrementButton
                    : AppColors.darkGreen.withValues(alpha: 0.7),
                fontSize: 14.sp,
                fontFamily: 'InriaSerif',
              )
                  : null,
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.black.withValues(alpha: 0.5),
                fontSize: 15.sp,
                fontFamily: 'InriaSerif',
              ),
              filled: true,
              fillColor: widget.fillColor ?? AppColors.designFieldPink,

              border: outlineInputBorder,
              enabledBorder: outlineInputBorder,
              focusedBorder: focusedOutlineInputBorder,
              errorBorder: outlineInputBorder.copyWith(
                borderSide: BorderSide(color: AppColors.error, width: 1.5),
              ),
              focusedErrorBorder: focusedOutlineInputBorder.copyWith(
                borderSide: BorderSide(color: AppColors.error, width: 2.0),
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
                      ? AppColors.iconColor
                      : AppColors.iconColor,
                  size: 22.r,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : null,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        );
      },
    );
  }
}