import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

class FlowerSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const FlowerSearchBar({super.key, this.controller, this.onChanged});

  @override
  State<FlowerSearchBar> createState() => _FlowerSearchBarState();
}

class _FlowerSearchBarState extends State<FlowerSearchBar>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _borderColorAnimation;

  late TextEditingController _internalController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Border width animation
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.5.w).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Border color animation
    _borderColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: AppColors.selectedCategory,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    // Initialize controller
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(_updateHasText);

    // Set initial text state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _hasText = _internalController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    } else {
      _internalController.removeListener(_updateHasText);
    }
    super.dispose();
  }

  void _updateHasText() {
    if (mounted) {
      setState(() {
        _hasText = _internalController.text.isNotEmpty;
      });
    }
  }

  void _clearText() {
    _internalController.clear();
    _hasText = false;
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: _borderColorAnimation.value ?? Colors.transparent,
              width: _borderAnimation.value,
            ),
            boxShadow: [
              BoxShadow(
                color: _focusNode.hasFocus
                    ? AppColors.darkGreen.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.06),
                offset: Offset(0, 2.h),
                blurRadius: _focusNode.hasFocus ? 8.r : 4.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: _internalController,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                _hasText = value.isNotEmpty;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Search for flowers',
              hintStyle: TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 14.sp,
                color: AppColors.iconColor.withValues(
                  alpha: _focusNode.hasFocus ? 0.9 : 0.7,
                ),
              ),
              prefixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Ionicons.search_outline,
                  key: ValueKey(_focusNode.hasFocus),
                  size: 20.r,
                  color: _focusNode.hasFocus
                      ? AppColors.darkGreen
                      : AppColors.iconColor,
                ),
              ),
              suffixIcon: _hasText
                  ? GestureDetector(
                      onTap: _clearText,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: 1.0,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.r,
                          color: AppColors.iconColor,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 16.w,
              ),
            ),
          ),
        );
      },
    );
  }
}
