import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
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
    this.style,
    this.inheritStyle = false,
  });

  final String text;
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
  final TextStyle? style;
  final bool inheritStyle;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final baseStyle =
        style ??
        (inheritStyle
            ? defaultStyle.style
            : const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ));
    return Text(
      text,
      textDirection: textDirection,
      textAlign:
          textAlign ??
          (inheritStyle ? defaultStyle.textAlign : TextAlign.start),
      maxLines: maxLines ?? (inheritStyle ? defaultStyle.maxLines : null),
      overflow: overflow ?? (inheritStyle ? defaultStyle.overflow : null),
      softWrap: inheritStyle ? defaultStyle.softWrap : null,
      style: baseStyle.copyWith(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      ),
    );
  }
}
