import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/account_model.dart';
import '../../../../../model/category_model.dart';
import '../../../cubit/account_cubit/cubit.dart';
import '../../../cubit/account_cubit/states.dart';
import '../../../cubit/category_cubit/cubit.dart';
import '../../../cubit/category_cubit/states.dart';

Future<String?> showUsernameSuggestionDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final categoryState = context.read<CategoryCubit>().state;
  final accountState = context.read<AccountCubit>().state;

  if (categoryState is! CategoryLoaded || accountState is! AccountLoaded) {
    return null;
  }

  final categoriesWithAccounts = categoryState.categories.where((category) {
    return accountState.accounts.any((acc) => acc.categoryId == category.id);
  }).toList();

  Category? selectedCategory;
  List<String> suggestions = [];

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              final title = selectedCategory == null
                  ? l10n.accountFormSelectCategoryTitle
                  : "${l10n.accountFormSelectEmailTitle} '${selectedCategory!.name}'";

              return Column(
                children: [
                  const _SheetHandle(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (selectedCategory != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => setModalState(() => selectedCategory = null),
                        ),
                      Expanded(
                        child: Text(title,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: selectedCategory == null
                          ? _CategoryList(
                        categories: categoriesWithAccounts,
                        accounts: accountState.accounts,
                        onCategorySelected: (cat, found) {
                          suggestions = found;
                          setModalState(() => selectedCategory = cat);
                        },
                        scrollController: scrollController,
                      )
                          : _UsernameList(
                        suggestions: suggestions,
                        scrollController: scrollController,
                        onSelected: (username) =>
                            Navigator.of(ctx).pop(username),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final List<Account> accounts;
  final void Function(Category, List<String>) onCategorySelected;
  final ScrollController scrollController;

  const _CategoryList({
    required this.categories,
    required this.accounts,
    required this.onCategorySelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('category_list'),
      controller: scrollController,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: const Icon(AppIcons.category),
          title: Text(category.name),
          onTap: () {
            final found = accounts
                .where((a) => a.categoryId == category.id)
                .map((a) => a.username)
                .toSet()
                .toList();
            onCategorySelected(category, found);
          },
        );
      },
    );
  }
}

class _UsernameList extends StatelessWidget {
  final List<String> suggestions;
  final ScrollController scrollController;
  final void Function(String) onSelected;

  const _UsernameList({
    required this.suggestions,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('username_list'),
      controller: scrollController,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final username = suggestions[index];
        return ListTile(
          leading: const Icon(AppIcons.user),
          title: Text(username, maxLines: 1),
          onTap: () => onSelected(username),
        );
      },
    );
  }
}
