import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_icons.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/empty_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../model/category_model.dart';
import '../home/cubit/account_cubit/cubit.dart';
import '../home/cubit/category_cubit/cubit.dart';
import '../home/cubit/category_cubit/states.dart';
import 'cubit/manage_categories_cubit.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageCategoriesCubit(),
      child: const ManageCategoriesView(),
    );
  }
}

class ManageCategoriesView extends StatelessWidget {
  const ManageCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        return BlocBuilder<ManageCategoriesCubit, ManageCategoriesState>(
          builder: (context, manageState) {
            final isSelectionMode = manageState.isSelectionMode;
            final selectedCount = manageState.selectedCategoryIds.length;
            final hasCategories =
                categoryState is CategoryLoaded &&
                categoryState.categories.isNotEmpty;

            return Scaffold(
              appBar: AppBar(
                leading: isSelectionMode
                    ? IconButton(
                        icon: const Icon(AppIcons.close),
                        onPressed: () => context
                            .read<ManageCategoriesCubit>()
                            .toggleSelectionMode(),
                      )
                    : null,
                title: Text(
                  isSelectionMode
                      ? l10n.manageCategoriesSelected(selectedCount)
                      : l10n.manageCategoriesTitle,
                ),
                actions: [
                  // --- CORRECTED LOGIC ---
                  if (isSelectionMode) ...[
                    if (selectedCount > 0)
                      IconButton(
                        icon: Icon(
                          AppIcons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _showMultiDeleteConfirmation(
                          context,
                          manageState.selectedCategoryIds,
                        ),
                      )
                    else if (hasCategories)
                      TextButton(
                        onPressed: () {
                          final allIds = categoryState.categories
                              .map((c) => c.id!)
                              .toList();
                          context
                              .read<ManageCategoriesCubit>()
                              .selectAllCategories(allIds);
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.manageCategoriesSelectAll,
                        ),
                      ),
                  ] else if (hasCategories) ...[
                    TextButton(
                      onPressed: () => context
                          .read<ManageCategoriesCubit>()
                          .toggleSelectionMode(),
                      child: Text(l10n.manageCategoriesSelect),
                    ),
                  ],
                ],
              ),
              body: _buildBody(context, categoryState, manageState),
              floatingActionButton: isSelectionMode
                  ? null
                  : FloatingActionButton(
                      onPressed: () => _showAddEditDialog(context),
                      child: const Icon(AppIcons.add),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CategoryState categoryState,
    ManageCategoriesState manageState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isSelectionMode = manageState.isSelectionMode;

    if (categoryState is CategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (categoryState is CategoryLoaded) {
      if (categoryState.categories.isEmpty) {
        return BuildEmptyWidget(
          title: l10n.manageCategoriesEmptyTitle,
          subTitle: l10n.manageCategoriesEmptySubTitle,
        );
      }
      return ReorderableListView.builder(
        buildDefaultDragHandles: !isSelectionMode,
        itemCount: categoryState.categories.length,
        itemBuilder: (context, index) {
          final category = categoryState.categories[index];
          final isSelected = manageState.selectedCategoryIds.contains(
            category.id,
          );

          return ListTile(
            key: ValueKey(category.id),
            leading: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => context
                        .read<ManageCategoriesCubit>()
                        .selectCategory(category.id!),
                  )
                : const Icon(AppIcons.category),
            title: CustomText(category.name, maxLines: 2),
            onTap: isSelectionMode
                ? () => context.read<ManageCategoriesCubit>().selectCategory(
                    category.id!,
                  )
                : null,
            trailing: !isSelectionMode
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(AppIcons.edit),
                        onPressed: () =>
                            _showAddEditDialog(context, category: category),
                      ),
                      IconButton(
                        icon: Icon(
                          AppIcons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () =>
                            _showSingleDeleteConfirmation(context, category),
                      ),
                      const Icon(Icons.drag_handle),
                    ],
                  )
                : null,
            selected: isSelected,
            selectedTileColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (!isSelectionMode) {
            context.read<CategoryCubit>().reorderCategories(oldIndex, newIndex);
          }
        },
      );
    }
    return Center(child: Text(l10n.errorGeneric));
  }

  void _showAddEditDialog(BuildContext context, {Category? category}) {
    final bool isEditing = category != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: isEditing ? category.name : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isEditing
              ? AppLocalizations.of(context)!.manageCategoriesEditDialogTitle
              : AppLocalizations.of(context)!.manageCategoriesAddDialogTitle,
        ),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: nameController,
            labelText: AppLocalizations.of(context)!.manageCategoriesNameHint,
            prefixIcon: AppIcons.createFolder,
            validator: (v) => v!.isEmpty
                ? AppLocalizations.of(context)!.validationCategoryNameEmpty
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cubit = context.read<CategoryCubit>();
                if (isEditing) {
                  final updatedCategory = category.copyWith(
                    name: nameController.text,
                  );
                  cubit.updateCategory(updatedCategory);
                } else {
                  cubit.addCategory(nameController.text);
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(
              isEditing
                  ? AppLocalizations.of(context)!.dialogSave
                  : AppLocalizations.of(context)!.dialogCreate,
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiDeleteConfirmation(
    BuildContext context,
    Set<int> categoryIds,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: CustomText(l10n.dialogConfirmDeleteTitle),
        content: CustomText(l10n.dialogConfirmDeleteMulti(categoryIds.length)),
        actions: [
          TextButton(
            child: CustomText(l10n.dialogCancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: CustomText(
              l10n.dialogDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () {
              // Perform the deletion
              context.read<CategoryCubit>().deleteMultipleCategories(
                categoryIds,
              );

              // Refresh the account list since accounts were also deleted
              context.read<AccountCubit>().loadAccounts();

              // Exit selection mode
              context.read<ManageCategoriesCubit>().toggleSelectionMode();

              // Close the dialog
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSingleDeleteConfirmation(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: CustomText(l10n.dialogConfirmDeleteTitle),
        content: CustomText(l10n.dialogConfirmDeleteCategory),
        actions: [
          TextButton(
            child: CustomText(l10n.dialogCancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: CustomText(
              l10n.dialogDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
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
}