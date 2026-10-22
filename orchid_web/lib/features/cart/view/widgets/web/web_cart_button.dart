import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';

/// Rounded desktop cart button (same look as the mobile `CustomButton`).
class WebCartButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const WebCartButton({
    super.key,
    required this.label,
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: borderColor != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor!, width: 1),
                  )
                : null,
            child: CustomText(
              text: label,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: fontSize,
              fontWeight: fontWeight,
              textColor: textColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
