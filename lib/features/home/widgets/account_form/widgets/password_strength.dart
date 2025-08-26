import 'package:flutter/material.dart';

import '../../../../../core/widgets/custom_text.dart';
import '../../../../../l10n/app_localizations.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;

  const PasswordStrengthIndicator(
      {super.key, required this.strength});

  Color _getStrengthColor(double strength) {
    if (strength < 0.5) return Colors.red;
    if (strength < 0.75) return Colors.orange;
    if (strength < 1.0) return Colors.lightGreen;
    return Colors.green;
  }

  String _getStrengthText(BuildContext context, double strength) {
    if (strength < 0.5) return AppLocalizations.of(context)!.passwordGeneratorWeak;
    if (strength < 0.75) return AppLocalizations.of(context)!.passwordGeneratorMedium;
    if (strength < 1.0) return AppLocalizations.of(context)!.passwordGeneratorStrong;
    return AppLocalizations.of(context)!.passwordGeneratorVeryStrong;
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0.0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          color: _getStrengthColor(strength),
          minHeight: 6,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        CustomText(
          _getStrengthText(context, strength),
          style: TextStyle(color: _getStrengthColor(strength), fontSize: 12),
        ),
      ],
    );
  }
}