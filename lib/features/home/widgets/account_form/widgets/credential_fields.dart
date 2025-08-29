import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:secure_accounts/features/home/widgets/account_form/widgets/password_strength.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../cubit/account_form/account_form_cubit.dart';
import '../../../cubit/account_form/account_form_state.dart';
import '../../../cubit/category_cubit/states.dart';
import '../../password_generator_dialog.dart';

class CredentialFields extends StatelessWidget {
  final AccountFormState formState;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final CategoryState categoryState;
  final VoidCallback onSuggestUsername;

  const CredentialFields({
    super.key,
    required this.formState,
    required this.usernameController,
    required this.passwordController,
    required this.categoryState,
    required this.onSuggestUsername,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final CategoryLoaded? loaded = categoryState is CategoryLoaded
        ? categoryState as CategoryLoaded
        : null;
    final bool showSuggestBtn =
        loaded != null && loaded.categories.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: usernameController,
                labelText: l10n.accountFormUsernameHint,
                prefixIcon: AppIcons.user,
                validator: (v) =>
                (v == null || v.isEmpty) ? l10n.validationEnterUsername : null,
              ),
            ),
            if (showSuggestBtn) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Iconsax.magicpen),
                onPressed: onSuggestUsername,
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: passwordController,
                labelText: l10n.accountDetailsPassword,
                prefixIcon: AppIcons.lock,
                isPassword: !formState.isPasswordVisible,
                validator: (v) =>
                (v == null || v.isEmpty) ? l10n.validationEnterPassword : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    formState.isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye,
                  ),
                  onPressed: () =>
                      context.read<AccountFormCubit>().togglePasswordVisibility(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Iconsax.magicpen),
              onPressed: () async {
                final newPassword = await showDialog<String>(
                  context: context,
                  builder: (_) => const PasswordGeneratorDialog(),
                );
                if (newPassword != null && newPassword.isNotEmpty) {
                  passwordController.text = newPassword;
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        PasswordStrengthIndicator(strength: formState.passwordStrength),
      ],
    );
  }
}
