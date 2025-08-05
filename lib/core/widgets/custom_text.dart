import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  const CustomText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines=1, this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final finalStyle = baseStyle?.merge(style);

    return Text(
      text,
      overflow: overflow,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}