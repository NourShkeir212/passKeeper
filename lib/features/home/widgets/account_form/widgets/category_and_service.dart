import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../cubit/account_form/account_form_cubit.dart';
import '../../../cubit/account_form/account_form_state.dart';
import '../../../cubit/category_cubit/states.dart';

class CategoryAndServiceFields extends StatelessWidget {
  final AccountFormState formState;
  final CategoryState categoryState;
  final TextEditingController otherServiceController;
  final List<String> services;
  final VoidCallback onCreateCategory;

  const CategoryAndServiceFields({
    super.key,
    required this.formState,
    required this.categoryState,
    required this.otherServiceController,
    required this.services,
    required this.onCreateCategory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Local cast so we can safely access .categories
    final CategoryLoaded? loaded = categoryState is CategoryLoaded
        ? categoryState as CategoryLoaded
        : null;

    return Column(
      children: [
        if (loaded != null)
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              fillColor: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              labelText: l10n.accountFormCategoryHint,
              prefixIcon: Icon(AppIcons.category, color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              ),
            ),

            value: formState.selectedCategoryId,
            items: [
              DropdownMenuItem(
                value: -1,
                child: Text(l10n.accountFormCreateCategory),
              ),
              ...loaded.categories.map(
                    (c) =>
                    DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.name),
                    ),
              ),
            ],
            onChanged: (newValue) {
              if (newValue == -1) {
                onCreateCategory();
              } else {
                context.read<AccountFormCubit>().selectCategory(newValue);
              }
            },
            validator: (v) =>
            (v == null || v == -1) ? l10n.validationSelectCategory : null,
          )
        else
          const SizedBox.shrink(), // or a small loading placeholder

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
              fillColor: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              labelText: l10n.accountFormCategoryHint,
              prefixIcon: Icon(AppIcons.category, color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              )
          ),
          value: formState.selectedService,
          items: services
              .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              context.read<AccountFormCubit>().selectService(val),
          validator: (v) => v == null ? l10n.validationSelectService : null,
        ),

        if (formState.selectedService == 'Other...')
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: CustomTextField(
              controller: otherServiceController,
              labelText: l10n.accountFormEnterServiceName,
              prefixIcon: AppIcons.edit,
              validator: (v) =>
              (v == null || v.isEmpty) ? l10n.validationEnterServiceName : null,
            ),
          ),

        const SizedBox(height: 10),
      ],
    );
  }
}