import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/custom_elevated_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/password_validation_rules.dart';
import '../home/cubit/account_cubit/cubit.dart';
import '../settings/cubit/cubit.dart';
import '../settings/cubit/states.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(),
      child: const ChangePasswordView(),
    );
  }
}

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String? validateNewPassword(String? value) {
      if (value == null || value.isEmpty) {
        return AppLocalizations.of(context)!.validationEnterPassword;
      }
      if (value.length < 8) {
        return AppLocalizations.of(context)!.signUpScreenPasswordRuleLength;
      }
      if (!RegExp(r'[a-zA-Z]').hasMatch(value) ||
          !RegExp(r'[0-9]').hasMatch(value) ||
          !RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
        return AppLocalizations.of(context)!.signUpScreenPasswordRuleLetters;
      }
      return null;
    }

    void submitChange() {
      if (formKey.currentState!.validate()) {
        context.read<SettingsCubit>().changeMasterPassword(
          context: context,
          oldPassword: oldPasswordController.text,
          newPassword: newPasswordController.text,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            // Refresh the account list to get newly re-encrypted data
            context.read<AccountCubit>().loadAccounts();
            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar( SnackBar(
                  content: Text(AppLocalizations.of(context)!.feedbackPasswordChanged),
                  backgroundColor: Colors.green));
            Navigator.of(context).pop();
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Theme.of(context).colorScheme.error));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.changePasswordTitle, // e.g., "Update your password"
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.changePasswordSubHeader, // e.g., "Your new password must be secure and different from the old one."
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: oldPasswordController,
                      labelText:AppLocalizations.of(context)!.changePasswordCurrent,
                      prefixIcon: AppIcons.lock,
                      isPassword: !state.isCurrentPasswordVisible,
                      validator: (v) => v!.isEmpty ?AppLocalizations.of(context)!.changePasswordCurrent : null,
                      suffixIcon: IconButton(
                        icon: Icon(state.isCurrentPasswordVisible ? AppIcons.eyeClosed : AppIcons.eye),
                        onPressed: () => context.read<ChangePasswordCubit>().toggleCurrentPasswordVisibility(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: newPasswordController,
                      labelText: AppLocalizations.of(context)!.changePasswordNew,
                      prefixIcon: AppIcons.lock,
                      isPassword: !state.isNewPasswordVisible,
                      validator: validateNewPassword,
                      onChanged: (password) => context.read<ChangePasswordCubit>().validatePasswordRealtime(password),
                      suffixIcon: IconButton(
                        icon: Icon(state.isNewPasswordVisible ? AppIcons.eyeClosed : AppIcons.eye),
                        onPressed: () => context.read<ChangePasswordCubit>().toggleNewPasswordVisibility(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return PasswordValidationRules(
                      isChange: true,
                      hasMinLength: state.hasMinLength,
                      hasLetter: state.hasLetter,
                      hasDigit: state.hasDigit,
                      hasSpecialChar: state.hasSpecialChar,
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: confirmPasswordController,
                      labelText: AppLocalizations.of(context)!.changePasswordConfirm,
                      prefixIcon: AppIcons.lock,
                      isPassword: !state.isConfirmPasswordVisible,
                      validator: (value) => value != newPasswordController.text ? AppLocalizations.of(context)!.validationPasswordsNoMatch : null,
                      suffixIcon: IconButton(
                        icon: Icon(state.isConfirmPasswordVisible ?  AppIcons.eyeClosed : AppIcons.eye),
                        onPressed: () => context.read<ChangePasswordCubit>().toggleConfirmPasswordVisibility(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      onPressed: submitChange,
                      text: AppLocalizations.of(context)!.changePasswordSaveButton,
                      isLoading: state is SettingsLoading,
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