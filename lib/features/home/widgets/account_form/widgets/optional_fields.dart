import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../l10n/app_localizations.dart';

class OptionalFields extends StatelessWidget {
  final TextEditingController recoveryController;
  final TextEditingController phoneController;
  final TextEditingController notesController;

  const OptionalFields({
    super.key,
    required this.recoveryController,
    required this.phoneController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CustomTextField(
          controller: recoveryController,
          labelText: l10n.accountFormRecoveryHint,
          prefixIcon: AppIcons.email,
          suffixIcon: IconButton(onPressed: recoveryController.clear, icon: const Icon(Icons.remove, color: Colors.red)),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: phoneController,
          labelText: l10n.accountFormPhoneHint,
          prefixIcon: AppIcons.phone,
          suffixIcon: IconButton(onPressed: phoneController.clear, icon: const Icon(Icons.remove, color: Colors.red)),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: notesController,
          labelText: l10n.notes,
          prefixIcon: Icons.notes,
          maxLines: null,
          suffixIcon: IconButton(onPressed: notesController.clear, icon: const Icon(Icons.remove, color: Colors.red)),
        ),
      ],
    );
  }
}
