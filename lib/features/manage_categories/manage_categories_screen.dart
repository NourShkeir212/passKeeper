import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                categoryState is CategoryLoaded && categoryState.categories.isNotEmpty;

            return Scaffold(
              appBar: AppBar(
                // --- UI UPDATE: Animated leading icon ---
                leading: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: isSelectionMode
                      ? IconButton(
                    key: const ValueKey('close_icon'),
                    icon: const Icon(AppIcons.close),
                    onPressed: () => context.read<ManageCategoriesCubit>().toggleSelectionMode(),
                  )
                      : const BackButton(),
                ),
                // --- Animated title ---
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isSelectionMode ? l10n.manageCategoriesSelected(selectedCount) : l10n.manageCategoriesTitle,
                    key: ValueKey(isSelectionMode),
                  ),
                ),
                actions: [
                  // --- Animated actions ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSelectionMode
                        ? (selectedCount > 0
                        ? IconButton(
                      key: const ValueKey('delete_icon'),
                      icon: Icon(AppIcons.delete, color: Theme.of(context).colorScheme.error),
                      onPressed: () => _showMultiDeleteConfirmation(context, manageState.selectedCategoryIds),
                    )
                        : TextButton(
                      key: const ValueKey('select_all_button'),
                      onPressed: () {
                        if (categoryState is CategoryLoaded) {
                          final allIds = categoryState.categories.map((c) => c.id!).toList();
                          context.read<ManageCategoriesCubit>().selectAllCategories(allIds);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.manageCategoriesSelectAll),
                    ))
                        : (hasCategories
                        ? TextButton(
                      key: const ValueKey('select_button'),
                      onPressed: () => context.read<ManageCategoriesCubit>().toggleSelectionMode(),
                      child: Text(l10n.manageCategoriesSelect),
                    )
                        : const SizedBox.shrink()),
                  ),
                ],
              ),
              body: _buildBody(context, categoryState, manageState),
              floatingActionButton: isSelectionMode
                  ? null
                  : FloatingActionButton(
                onPressed: () => _showAddEditDialog(context),
                child: const Icon(AppIcons.add),
              ).animate().scale(),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CategoryState categoryState, ManageCategoriesState manageState) {
    final l10n = AppLocalizations.of(context)!;
    final isSelectionMode = manageState.isSelectionMode;

    if (categoryState is CategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (categoryState is CategoryLoaded) {
      if (categoryState.categories.isEmpty) {
        return BuildEmptyWidget(
          title: l10n.manageCategoriesEmptyTitle,
          subTitle: l10n.manageCategoriesEmptySubTitle
        );
      }
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(8.0),
        buildDefaultDragHandles: !isSelectionMode,
        itemCount: categoryState.categories.length,
        itemBuilder: (context, index) {
          final category = categoryState.categories[index];
          final isSelected = manageState.selectedCategoryIds.contains(
              category.id);
          return Card(
              key: ValueKey(category.id),
              elevation: isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Theme
                      .of(context)
                      .colorScheme
                      .primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (isSelectionMode) {
                    context.read<ManageCategoriesCubit>().selectCategory(
                        category.id!);
                  } else {
                    _showAddEditDialog(context, category: category);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      if (isSelectionMode)
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) =>
                              context
                                  .read<ManageCategoriesCubit>()
                                  .selectCategory(category.id!),
                        )
                      else
                         Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(AppIcons.category,color: Theme.of(context).primaryColor,),
                        ),
                      const SizedBox(width: 8),
                      Expanded(child: CustomText(category.name)),
                      if (!isSelectionMode) ...[
                        IconButton(
                          icon: const Icon(AppIcons.edit),
                          onPressed: () =>
                              _showAddEditDialog(context, category: category),
                        ),
                        IconButton(
                          icon:  Icon(AppIcons.delete,color: Theme.of(context).colorScheme.error),
                          onPressed: () =>
                              _showSingleDeleteConfirmation(context,category),
                        ),
                        IconButton(
                          icon:  Icon(Icons.drag_handle),
                          onPressed: () {}
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (50 * index).ms)
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
        content: CustomText(l10n.dialogConfirmDeleteMulti(categoryIds.length,),maxLines: 5,),
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
        content: CustomText(l10n.dialogConfirmDeleteCategory,maxLines: 5,),
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
