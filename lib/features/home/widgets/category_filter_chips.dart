import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../../model/category_model.dart';
import '../cubit/account_cubit/cubit.dart';
import '../cubit/category_cubit/cubit.dart';
import '../cubit/category_cubit/states.dart';

class CategoryFilterChips extends StatefulWidget {
  const CategoryFilterChips({super.key});

  @override
  State<CategoryFilterChips> createState() => CategoryFilterChipsState();
}

class CategoryFilterChipsState extends State<CategoryFilterChips> {
  int? selectedCategoryId;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    // Estimate the position to scroll to. You can adjust this value.
    const double chipWidth = 100.0;
    _scrollController.animateTo(
      index * chipWidth,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void selectCategoryByIndex(int index, List<Category> categories) {
    int? newCategoryId;
    if (index == 0) {
      newCategoryId = null; // "All" selected
    } else if (index > 0 && index <= categories.length) {
      newCategoryId = categories[index - 1].id;
    } else {
      return; // Index out of bounds
    }

    setState(() {
      selectedCategoryId = newCategoryId;
    });
    context.read<AccountCubit>().filterByCategory(selectedCategoryId);
    _scrollToIndex(index);
  }
  @override
  Widget build(BuildContext context) {
    // Get the primary color and the color for text on a primary background
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        if (categoryState is CategoryLoaded && categoryState.categories.isNotEmpty) {
          return SizedBox(
            height: 50,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: categoryState.categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                // --- "All" Chip ---
                if (index == 0) {
                  final isSelected = selectedCategoryId == null;
                  return ChoiceChip(
                    checkmarkColor: Theme.of(context).colorScheme.background,
                    label:  Text(AppLocalizations.of(context)!.homeScreenAllChipTitle),
                    selected: isSelected,
                    onSelected: (isSelected) {
                      setState(() => selectedCategoryId = null);
                      context.read<AccountCubit>().filterByCategory(null);
                      _scrollToIndex(0);
                    },
                    // --- APPLY THEME COLORS ---
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? onPrimaryColor : null,
                    ),
                  );
                }
                // --- Category Chips ---
                final category = categoryState.categories[index - 1];
                final isSelected = selectedCategoryId == category.id;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedCategoryId = isSelected ? category.id : null;
                    });
                    context.read<AccountCubit>().filterByCategory(selectedCategoryId);
                    _scrollToIndex(index);
                  },
                  // --- APPLY THEME COLORS ---
                  checkmarkColor: Theme.of(context).colorScheme.background,
                  selectedColor: primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? onPrimaryColor : null,
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
