import 'package:flutter/material.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

Future<String?> showMasterPasswordDialog(BuildContext context, {String? title, String? content}) {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title ?? AppLocalizations.of(context)!.dialogUnlockVaultTitle),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content ?? AppLocalizations.of(context)!.dialogUnlockToContinue),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.accountFormPasswordHint),
              validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.validationEnterPassword : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:  Text(AppLocalizations.of(context)!.dialogCancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop(passwordController.text);
            }
          },
          child:  Text(AppLocalizations.of(context)!.dialogUnlock),
        ),
      ],
    ),
  );
}