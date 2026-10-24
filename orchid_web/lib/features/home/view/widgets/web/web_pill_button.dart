import 'package:flutter/material.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Pill button component used in the hero and promotional sections.
class WebPillButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const WebPillButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<WebPillButton> createState() => _WebPillButtonState();
}

class _WebPillButtonState extends State<WebPillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const brandGreen = AppColors.storeDeepGreen;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? AppColors.storeGreenHover : brandGreen)
                : (_hovered
                      ? brandGreen.withValues(alpha: 0.08)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: brandGreen, width: 1.2),
          ),
          child: CustomText(
            text: widget.label,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textColor: widget.filled ? Colors.white : brandGreen,
          ),
        ),
      ),
    );
  }
}
