import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.textColor,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textDirection = TextDirection.ltr,
    this.letterSpacing,
    this.height,
    this.fontFamily,
    this.shadows,
  });

  final String text;
  final TextStyle? style;
  final Color? textColor;
  final double? fontSize;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;
  final double? height;
  final TextOverflow? overflow;
  final TextDirection? textDirection;
  final String? fontFamily;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final overrides = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
    );

    final effectiveStyle = style == null
        ? overrides.copyWith(
            color: textColor ?? Colors.black,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontWeight.normal,
          )
        : style!.merge(overrides);

    return Text(
      text,
      textDirection: textDirection,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
      style: effectiveStyle,
    );
  }
}
