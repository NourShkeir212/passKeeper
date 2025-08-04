import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../l10n/app_localizations.dart';
import 'custom_text.dart';

class PasswordValidationRules extends StatelessWidget {
  final bool hasMinLength;
  final bool hasLetter;
  final bool hasDigit;
  final bool hasSpecialChar;

  const PasswordValidationRules({
    super.key,
    required this.hasMinLength,
    required this.hasLetter,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    // Show the rules only if the user has started typing
    if (hasMinLength || hasLetter || hasDigit || hasSpecialChar) {
      return Column(
        children: [
          _ValidationRuleItem(
            text: AppLocalizations.of(context)!.signUpScreenPasswordRuleLength,
            isValid: hasMinLength,
          ),
          _ValidationRuleItem(
            text: AppLocalizations.of(context)!.signUpScreenPasswordRuleLetters,
            isValid: hasLetter,
          ),
          _ValidationRuleItem(
            text: AppLocalizations.of(context)!.signUpScreenPasswordRuleNumbers,
            isValid: hasDigit,
          ),
          _ValidationRuleItem(
            text: AppLocalizations.of(context)!.signUpScreenPasswordRuleSpecial,
            isValid: hasSpecialChar,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms);
    }
    // Otherwise, return an empty widget
    return const SizedBox.shrink();
  }
}

class _ValidationRuleItem extends StatelessWidget {
  final String text;
  final bool isValid;
  const _ValidationRuleItem({required this.text, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final color = isValid
        ? Colors.green
        : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle_outline : Icons.remove_circle_outline,
              color: color, size: 18),
          const SizedBox(width: 8),
          CustomText(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}