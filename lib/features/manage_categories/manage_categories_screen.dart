import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../model/category_model.dart';
import '../home/cubit/account_cubit/cubit.dart';
import '../home/cubit/category_cubit/cubit.dart';
import '../home/cubit/category_cubit/states.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.manageCategoriesTitle),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return  _buildEmptyState(context);
            }
            return ReorderableListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  // Each item MUST have a unique key for reordering
                  key: ValueKey(category.id),
                  leading: const Icon(AppIcons.category),
                  title: CustomText(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(AppIcons.edit),
                        onPressed: () => _showAddEditDialog(context, category: category),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _showDeleteConfirmation(context, category),
                      ),
                      // The drag handle is implicitly the whole ListTile
                    ],
                  ),
                );
              },
              // The callback that triggers when an item is moved
              onReorder: (oldIndex, newIndex) {
                context.read<CategoryCubit>().reorderCategories(oldIndex, newIndex);
              },
            );
          }
          return  Center(child: Text("Could not load categories."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(AppIcons.add),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Category? category}) {
    final bool isEditing = category != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: isEditing ? category.name : '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? AppLocalizations.of(context)!.manageCategoriesEditDialogTitle : AppLocalizations.of(context)!.manageCategoriesAddDialogTitle),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: nameController,
            labelText: AppLocalizations.of(context)!.manageCategoriesNameHint,
            prefixIcon: AppIcons.createFolder,
            validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.validationCategoryNameEmpty : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child:  Text(AppLocalizations.of(context)!.dialogCancel)),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cubit = context.read<CategoryCubit>();
                if (isEditing) {
                  final updatedCategory = category.copyWith(name: nameController.text);
                  cubit.updateCategory(updatedCategory);
                } else {
                  cubit.addCategory(nameController.text);
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(isEditing ? AppLocalizations.of(context)!.dialogSave : AppLocalizations.of(context)!.dialogCreate),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:  CustomText(AppLocalizations.of(context)!.dialogConfirmDeleteTitle),
        content:  CustomText(AppLocalizations.of(context)!.dialogConfirmDeleteCategory),
        actions: [
          TextButton(child:  CustomText(AppLocalizations.of(context)!.dialogCancel), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: CustomText(AppLocalizations.of(context)!.dialogDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id!);
              context.read<AccountCubit>().loadAccounts();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/no_data.svg', // Ensure you have this file
              height: 150,
            ),
            const SizedBox(height: 24),
            CustomText(
              AppLocalizations.of(context)!.manageCategoriesEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            CustomText(
              AppLocalizations.of(context)!.manageCategoriesEmptySubTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}