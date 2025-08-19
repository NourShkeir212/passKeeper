import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:secure_accounts/features/auth/screens/sign_in/sign_in_screen.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../cubit/auth_cubit/cubit.dart';
import '../../cubit/auth_cubit/states.dart';
class SignUpMirrorScreen extends StatelessWidget {
  final String realUsername;
  const SignUpMirrorScreen({super.key, required this.realUsername});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final decoyUsername = '${realUsername}1';
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mirrorAccountTitle),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Iconsax.eye_slash, size: 80),
              const SizedBox(height: 24),
              CustomText(
                l10n.mirrorAccountSubtitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomText(
                l10n.mirrorAccountDescription,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 48),

              // Display the decoy username (read-only)
              AbsorbPointer(
                child: CustomTextField(
                  controller: TextEditingController(text: decoyUsername),
                  labelText: l10n.mirrorAccountDecoyUsernameHint,
                  prefixIcon: AppIcons.user,
                ),
              ),
              const SizedBox(height: 16),

              // Decoy password field
              CustomTextField(
                controller: passwordController,
                labelText: l10n.mirrorAccountDecoyPasswordHint,
                prefixIcon: AppIcons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validationPasswordEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthMirrorSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.mirrorAccountSuccess), backgroundColor: Colors.green),
                    );
                    NavigationService.pushAndRemoveUntil(const SignInScreen());
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().createMirrorAccount(
                          decoyUsername: decoyUsername,
                          decoyPassword: passwordController.text,
                          customization: {},
                        );
                      }
                    },
                    text: l10n.mirrorAccountCompleteButton,
                    isLoading: state is AuthLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  NavigationService.pushAndRemoveUntil(const SignInScreen());
                },
                child: Text(l10n.mirrorAccountSkipButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}