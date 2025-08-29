import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../cubit/category_cubit/cubit.dart';

Future<void> showCreateCategoryDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  final newCategory = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.manageCategoriesAddDialogTitle),
      content: CustomTextField(
        controller: controller,
        labelText: l10n.manageCategoriesNameHint,
        prefixIcon: AppIcons.createFolder,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(ctx, name);
            }
          },
          child: Text(l10n.dialogCreate),
        ),
      ],
    ),
  );

  if (newCategory != null && newCategory.isNotEmpty) {
    context.read<CategoryCubit>().addCategory(newCategory);
  }
}