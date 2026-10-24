import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

/// Desktop header action link with icon, label, and optional count badge.
class WebTopNavActionLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const WebTopNavActionLink({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.badgeCount = 0,
  });

  @override
  State<WebTopNavActionLink> createState() => _WebTopNavActionLinkState();
}

class _WebTopNavActionLinkState extends State<WebTopNavActionLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const defaultColor = AppColors.storeDeepGreen;
    final color = widget.isSelected
        ? AppColors.storeRose
        : (_hovered ? AppColors.storeRose : defaultColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(widget.icon, size: 19, color: color),
                if (widget.badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.storeRose,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      constraints: const BoxConstraints(minWidth: 15),
                      child: CustomText(
                        text: '${widget.badgeCount}',
                        textAlign: TextAlign.center,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6),
            CustomText(
              text: widget.label,
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              textColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
