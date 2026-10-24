import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Circular occasion avatar with hover and selected states.
class WebOccasionCircleItem extends StatefulWidget {
  final String name;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const WebOccasionCircleItem({
    super.key,
    required this.name,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<WebOccasionCircleItem> createState() => _WebOccasionCircleItemState();
}

class _WebOccasionCircleItemState extends State<WebOccasionCircleItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              transform: Matrix4.translationValues(0, active ? -4 : 0, 0),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected
                    ? AppColors.textFieldPink
                    : AppColors.storeCircleBg,
                border: Border.all(
                  color: active
                      ? AppColors.storeRose
                      : AppColors.storeCircleBorder,
                  width: widget.isSelected ? 2.5 : 2,
                ),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: AppColors.storeRose.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(widget.iconAsset, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CustomText(
              text: widget.name,
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
              textColor: widget.isSelected
                  ? AppColors.storeRose
                  : AppColors.storeLabel,
            ),
          ],
        ),
      ),
    );
  }
}
