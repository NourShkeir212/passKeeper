import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/secret_item_model.dart';
import '../cubits/secret_vault_cubit.dart';

class AddSecretItemDialog extends StatefulWidget {
  final SecretItem? itemToEdit;
  const AddSecretItemDialog({super.key, this.itemToEdit});

  @override
  State<AddSecretItemDialog> createState() => _AddSecretItemDialogState();
}

class _AddSecretItemDialogState extends State<AddSecretItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.itemToEdit != null;
    _titleController = TextEditingController(text: _isEditing ? widget.itemToEdit!.title : '');
    _contentController = TextEditingController(
      // The content must be decrypted for editing
        text: _isEditing ? EncryptionService().decryptText(widget.itemToEdit!.content) : ''
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isEditing ? l10n.secretVaultEditItemTitle : l10n.secretVaultAddItemTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: l10n.secretVaultTitleHint,
                validator: (value) => value!.isEmpty ? l10n.validationTitleEmpty : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                labelText: l10n.secretVaultContentHint,
                maxLines: 5,
                validator: (value) => value!.isEmpty ? l10n.validationContentEmpty : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
          child: Text(l10n.dialogCancel),
        ),
        CustomElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final cubit = context.read<SecretVaultCubit>();
              if (_isEditing) {
                final updatedItem = widget.itemToEdit!.copyWith(
                  title: _titleController.text,
                  content: _contentController.text,
                );
                cubit.updateSecretItem(updatedItem);
              } else {
                cubit.addSecretItem(
                  title: _titleController.text,
                  content: _contentController.text,
                );
              }
              Navigator.of(context).pop(true);
            }
          },
          text: l10n.dialogSave,
        ),
      ],
    );
  }
}