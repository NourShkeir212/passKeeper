import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../cubit/account_cubit/cubit.dart';
import '../cubit/category_cubit/cubit.dart';
import '../cubit/category_cubit/states.dart';

class CategoryFilterChips extends StatefulWidget {
  const CategoryFilterChips({super.key});

  @override
  State<CategoryFilterChips> createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  int? _selectedCategoryId;

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: categoryState.categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                // --- "All" Chip ---
                if (index == 0) {
                  final isSelected = _selectedCategoryId == null;
                  return ChoiceChip(
                    checkmarkColor: Theme.of(context).colorScheme.background,
                    label:  Text(AppLocalizations.of(context)!.homeScreenAllChipTitle),
                    selected: isSelected,
                    onSelected: (isSelected) {
                      setState(() => _selectedCategoryId = null);
                      context.read<AccountCubit>().filterByCategory(null);
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
                final isSelected = _selectedCategoryId == category.id;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (isSelected) {
                    setState(() {
                      _selectedCategoryId = isSelected ? category.id : null;
                    });
                    context.read<AccountCubit>().filterByCategory(_selectedCategoryId);
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
