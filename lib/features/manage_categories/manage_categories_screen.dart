import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
        title: const Text("Manage Categories"),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/no_data.svg',
                        height: 150,
                      ),
                      const SizedBox(height: 24),
                      CustomText(
                        "No categories created yet.",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        "Tap the '+' button to add your category",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
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
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Could not load categories."));
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
        title: Text(isEditing ? "Edit Category" : "Add New Category"),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: nameController,
            labelText: "Category Name",
            prefixIcon: AppIcons.createFolder,
            validator: (v) => v!.isEmpty ? "Name cannot be empty" : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cubit = context.read<CategoryCubit>();
                if (isEditing) {
                  final updatedCategory = Category(id: category.id, userId: category.userId, name: nameController.text);
                  cubit.updateCategory(updatedCategory);
                } else {
                  cubit.addCategory(nameController.text);
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(isEditing ? "Save" : "Create"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const CustomText('Confirm Deletion'),
        content: const CustomText('Are you sure you want to delete this category? All accounts within it will also be deleted.'),
        actions: [
          TextButton(child: const CustomText('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: CustomText('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id!);
              // We also need to refresh the main account list
              context.read<AccountCubit>().loadAccounts();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}