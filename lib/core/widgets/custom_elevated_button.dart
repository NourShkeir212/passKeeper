import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor, // NEW
  });

  @override
  Widget build(BuildContext context) {
    // Get the default style from the app's theme
    final ButtonStyle? themeStyle = Theme.of(context).elevatedButtonTheme.style;

    // Create a new style only if a custom background color is provided
    final ButtonStyle finalStyle = backgroundColor != null
        ? (themeStyle?.copyWith(
      backgroundColor: WidgetStateProperty.all(backgroundColor),
    ) ?? ElevatedButton.styleFrom(backgroundColor: backgroundColor))
        : themeStyle ?? ElevatedButton.styleFrom();

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: finalStyle,
      child: isLoading
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      )
          : Text(text),
    );
  }
}