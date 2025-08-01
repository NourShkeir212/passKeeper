import 'package:flutter/material.dart';
import 'package:secure_accounts/core/widgets/custom_text.dart';
import '../../../core/widgets/custom_text_button.dart';

class AuthLinkText extends StatelessWidget {
  final String leadingText;
  final String linkText;
  final VoidCallback onPressed;

  const AuthLinkText({
    super.key,
    required this.leadingText,
    required this.linkText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(leadingText),
        CustomTextButton(
          onPressed: onPressed,
          text: linkText,
        ),
      ],
    );
  }
}