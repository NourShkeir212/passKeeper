import 'package:flutter/material.dart';

import '../../../../../core/widgets/custom_elevated_button.dart';
import '../../../../../l10n/app_localizations.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: onPressed,
          text: l10n.accountFormSaveButton,
        ),
      ),
    );
  }
}