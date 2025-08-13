import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:secure_accounts/core/theme/app_icons.dart';

import '../../core/widgets/custom_elevated_button.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../settings/cubit/cubit.dart';
import '../settings/cubit/states.dart';
import 'cubit/delete_account_cubit.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the new UI cubit to the widget tree
    return BlocProvider(
      create: (context) => DeleteAccountCubit(),
      child: const DeleteAccountView(),
    );
  }
}

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is DeleteUserSuccess) {
          context.read<AuthCubit>().logout();
        } else if (state is DeleteUserFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.deleteAccountScreenTitle),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .error,
                ),
                const SizedBox(height: 24),
                CustomText(
                  l10n.deleteAccountWarningTitle,
                  maxLines: 3,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomText(
                  maxLines: 10,
                  l10n.deleteAccountWarningBody,
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 48),
                CustomText(
                  l10n.deleteAccountConfirmationPrompt,
                  maxLines: 3,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(height: 16),

                // --- UPDATED PASSWORD FIELD ---
                BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: passwordController,
                      labelText: l10n.changePasswordCurrent,
                      prefixIcon: Iconsax.key_square,
                      isPassword: !state.isPasswordVisible,
                      // Use state from cubit
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationPasswordEmpty;
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                            state.isPasswordVisible
                                ? AppIcons.eyeClosed
                                : AppIcons.eye
                        ),
                        onPressed: () {
                          // Call the method on the cubit
                          context
                              .read<DeleteAccountCubit>()
                              .togglePasswordVisibility();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return CustomElevatedButton(

                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            builder: (dialogContext) =>
                                AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.dialogConfirmDeleteAllDataTitle),
                                  content: Text(AppLocalizations.of(context)!
                                      .dialogConfirmDeleteAllDataContent),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(),
                                      child: Text(AppLocalizations.of(context)!
                                          .dialogCancel),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Close the dialog first
                                        Navigator.of(dialogContext).pop();
                                        // Then call the deleteAccount method
                                        context
                                            .read<SettingsCubit>()
                                            .deleteUserAccount(
                                            passwordController.text, context);
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .dialogDeleteForever,
                                        style: TextStyle(color: Theme
                                            .of(context)
                                            .colorScheme
                                            .error),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                      text: l10n.settingsDeleteAllData,
                      isLoading: state is SettingsLoading,
                      backgroundColor: Theme
                          .of(context)
                          .colorScheme
                          .error,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}