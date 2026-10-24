import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

/// Desktop navigation text link with hover underline and selected state.
class WebTopNavTextLink extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const WebTopNavTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<WebTopNavTextLink> createState() => _WebTopNavTextLinkState();
}

class _WebTopNavTextLinkState extends State<WebTopNavTextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.storeDeepGreen;
    final textColor = widget.isSelected
        ? activeColor
        : (_hovered ? AppColors.storeRose : AppColors.storeNavText);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: widget.label,
                fontFamily: AppFonts.inriaSerif,
                fontSize: 15,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                textColor: textColor,
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: widget.isSelected ? 28 : (_hovered ? 16 : 0),
                height: 2,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? activeColor
                      : AppColors.storeRose.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
