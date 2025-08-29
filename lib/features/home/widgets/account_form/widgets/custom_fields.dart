import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../l10n/app_localizations.dart';

class CustomFieldsSection extends StatelessWidget {
  final List<Map<String, TextEditingController>> customFields;
  final int maxCustomFields;
  final VoidCallback onChanged;

  const CustomFieldsSection({
    super.key,
    required this.customFields,
    required this.maxCustomFields,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fieldsLeft = maxCustomFields - customFields.length;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.customFieldsTitle, style: Theme.of(context).textTheme.titleMedium),
              if (customFields.length < maxCustomFields)
                Text(l10n.customFieldsLeft(fieldsLeft), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          ...customFields.asMap().entries.map((entry) {
            final i = entry.key;
            final field = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    CustomTextField(controller: field['key']!, labelText: l10n.customFieldsFieldName, prefixIcon: Iconsax.tag),
                    const SizedBox(height: 12),
                    CustomTextField(controller: field['value']!, labelText: l10n.customFieldsValue, prefixIcon: Iconsax.keyboard),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          customFields.removeAt(i);
                          onChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (customFields.length < maxCustomFields)
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: Text(l10n.customFieldsAddButton),
                onPressed: () {
                  customFields.add({'key': TextEditingController(), 'value': TextEditingController()});
                  onChanged();
                },
              ),
            ),
        ],
      ),
    );
  }
}
