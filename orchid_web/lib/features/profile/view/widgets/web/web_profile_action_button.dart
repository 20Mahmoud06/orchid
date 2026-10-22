import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_fonts.dart';

/// Full-width desktop action button (Log Out / Delete Account).
class WebProfileActionButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Color background;
  final Color textColor;
  final VoidCallback onPressed;

  const WebProfileActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
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
