import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_elevated_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../settings/cubit/cubit.dart';
import '../settings/cubit/states.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String? validateNewPassword(String? value) {
      if (value == null || value.isEmpty) return 'Please enter a new password';
      if (value.length < 8) return 'Password must be at least 8 characters';
      // Add other validation rules as needed
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
                CustomTextField(
                  controller: oldPasswordController,
                  labelText: "Current Password",
                  prefixIcon: Icons.lock_open,
                  isPassword: true,
                  validator: (v) => v!.isEmpty ? 'Please enter your current password' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: newPasswordController,
                  labelText: "New Password",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: validateNewPassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: confirmPasswordController,
                  labelText: "Confirm New Password",
                  prefixIcon: Icons.lock_person,
                  isPassword: true,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
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