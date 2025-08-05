import 'package:flutter/material.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

import '../theme/app_icons.dart';

Future<String?> showMasterPasswordDialog(BuildContext context, {String? title, String? content}) {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
                    obscureText: !isPasswordVisible,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.accountFormPasswordHint,
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye),
                        onPressed: () {
                          setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.validationPasswordEmpty : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.dialogCancel),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(passwordController.text);
                  }
                },
                child: Text(AppLocalizations.of(context)!.dialogUnlock),
              ),
            ],
          );
        },
      );
    },
  );
}
