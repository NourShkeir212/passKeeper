import 'package:flutter/material.dart';
import '../../../core/services/password_generator_service.dart';
import '../../../core/widgets/custom_expandable_text.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../l10n/app_localizations.dart';


class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() => _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = PasswordGeneratorService.generatePassword(
        length: _length.toInt(),
        includeUppercase: _includeUppercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;


    return AlertDialog(
      title: Text(l10n.passwordGeneratorTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display generated password
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              // --- USE THE NEW REUSABLE WIDGET ---
              child: CustomExpandableText(
                _generatedPassword,
                style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
              ),
            ),

            const SizedBox(height: 16),
            // Length slider and Checkboxes...
            Row(
              children: [
                CustomText("${l10n.passwordGeneratorLength} "),
                Expanded(
                  child: Slider(
                    value: _length,
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: _length.toInt().toString(),
                    onChanged: (value) {
                      setState(() => _length = value);
                      _generatePassword();
                    },
                  ),
                ),
                CustomText(_length.toInt().toString()),
              ],
            ),
            CheckboxListTile(
              title: Text(l10n.passwordGeneratorUppercase),
              value: _includeUppercase,
              onChanged: (value) {
                setState(() => _includeUppercase = value!);
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: Text(l10n.passwordGeneratorNumbers),
              value: _includeNumbers,
              onChanged: (value) {
                setState(() => _includeNumbers = value!);
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: Text(l10n.passwordGeneratorSymbols),
              value: _includeSymbols,
              onChanged: (value) {
                setState(() => _includeSymbols = value!);
                _generatePassword();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_generatedPassword),
          child: Text(l10n.passwordGeneratorUseButton),
        ),
      ],
    );
  }
}