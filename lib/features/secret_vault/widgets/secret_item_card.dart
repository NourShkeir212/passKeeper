import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/encryption_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../model/secret_item_model.dart';

class SecretItemCard extends StatefulWidget {
  final SecretItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SecretItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SecretItemCard> createState() => _SecretItemCardState();
}

class _SecretItemCardState extends State<SecretItemCard> {
  bool _isContentVisible = false;

  @override
  Widget build(BuildContext context) {
    final String plainTextContent = EncryptionService().decryptText(widget.item.content);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit and Delete buttons
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    widget.item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.edit, size: 20),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: Icon(AppIcons.delete, size: 20, color: Theme.of(context).colorScheme.error),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const Divider(height: 24),
            // Content Row
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    _isContentVisible ? plainTextContent : '••••••••••',
                    style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: Icon(_isContentVisible ? AppIcons.eyeSlash : AppIcons.eye),
                  onPressed: () => setState(() => _isContentVisible = !_isContentVisible),
                ),
                IconButton(
                  icon: const Icon(AppIcons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: plainTextContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Content copied to clipboard!")),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}