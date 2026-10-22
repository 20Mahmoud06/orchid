import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';

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
