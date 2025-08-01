import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const CustomText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final finalStyle = baseStyle?.merge(style);

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
    );
  }
}