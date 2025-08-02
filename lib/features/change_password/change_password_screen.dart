import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_elevated_button.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../settings/cubit/cubit.dart';
import '../settings/cubit/states.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the new UI cubit to the screen
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
      if (value == null || value.isEmpty) return 'Please enter a new password';
      if (value.length < 8) return 'Password must be at least 8 characters';
      if (!RegExp(r'[a-zA-Z]').hasMatch(value) ||
          !RegExp(r'[0-9]').hasMatch(value) ||
          !RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
        return 'Must contain letters, numbers, and symbols';
      }
      return null;
    }

    void submitChange() {
      if (formKey.currentState!.validate()) {
        context.read<SettingsCubit>().changePassword(
          oldPassword: oldPasswordController.text,
          newPassword: newPasswordController.text,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                  content: Text("Password changed successfully!"),
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
                // --- Current Password Field ---
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: oldPasswordController,
                      labelText: "Current Password",
                      prefixIcon: Icons.lock_open,
                      isPassword: !state.isCurrentPasswordVisible,
                      validator: (v) => v!.isEmpty ? 'Please enter your current password' : null,
                      suffixIcon: IconButton(
                        icon: Icon(state.isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => context.read<ChangePasswordCubit>().toggleCurrentPasswordVisibility(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // --- New Password Field ---
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: newPasswordController,
                      labelText: "New Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: !state.isNewPasswordVisible,
                      validator: validateNewPassword,
                      onChanged: (password) => context.read<ChangePasswordCubit>().validatePasswordRealtime(password),
                      suffixIcon: IconButton(
                        icon: Icon(state.isNewPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => context.read<ChangePasswordCubit>().toggleNewPasswordVisibility(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // --- Real-time Validation Rules ---
                const _PasswordValidationRules(),

                const SizedBox(height: 12),

                // --- Confirm Password Field ---
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomTextField(
                      controller: confirmPasswordController,
                      labelText: "Confirm New Password",
                      prefixIcon: Icons.lock_person,
                      isPassword: !state.isConfirmPasswordVisible,
                      validator: (value) => value != newPasswordController.text ? "Passwords do not match" : null,
                      suffixIcon: IconButton(
                        icon: Icon(state.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
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
                      text: "Save Changes",
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

// --- Reusable Password Validation Widget ---
class _PasswordValidationRules extends StatelessWidget {
  const _PasswordValidationRules();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
      builder: (context, state) {
        return Column(
          children: [
            _ValidationRuleItem(text: 'At least 8 characters', isValid: state.hasMinLength),
            _ValidationRuleItem(text: 'Contains letters', isValid: state.hasLetter),
            _ValidationRuleItem(text: 'Contains numbers', isValid: state.hasDigit),
            _ValidationRuleItem(text: 'Contains a special character', isValid: state.hasSpecialChar),
          ],
        );
      },
    );
  }
}

class _ValidationRuleItem extends StatelessWidget {
  final String text;
  final bool isValid;
  const _ValidationRuleItem({required this.text, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final color = isValid ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle_outline : Icons.remove_circle_outline, color: color, size: 18),
          const SizedBox(width: 8),
          CustomText(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}