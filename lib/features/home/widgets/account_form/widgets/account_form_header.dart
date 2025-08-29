import 'package:flutter/material.dart';

import '../../../../../core/widgets/custom_text.dart';
import '../../../../../l10n/app_localizations.dart';

class AccountFormHeader extends StatelessWidget {
  final bool isEdit;
  const AccountFormHeader({super.key, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 20),
        CustomText(
          isEdit ? l10n.accountFormEditTitle : l10n.accountFormAddTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
