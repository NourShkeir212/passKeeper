import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../cubit/auth_cubit/cubit.dart';
import '../../cubit/auth_cubit/states.dart';
import '../../widgets/auth_link_text.dart';
import '../sign_in/sign_in_screen.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // Helper functions can be defined locally.
    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a password';
      }
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
      final hasDigit = RegExp(r'[0-9]').hasMatch(value);
      final hasSpecialChar = RegExp(r'[^a-zA-Z0-9]').hasMatch(value);
      if (!hasLetter || !hasDigit || !hasSpecialChar) {
        return 'Password must contain letters, numbers, and a special character.';
      }
      return null;
    }

    void createAccount() {
      FocusScope.of(context).unfocus();
      if (formKey.currentState!.validate()) {
        context.read<AuthCubit>().signUp(
          username: usernameController.text.trim(),
          password: passwordController.text,
        );
      }
    }

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessSignUp) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Please Sign in.'),
                backgroundColor: Colors.green,
              ),
            );
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignInScreen()));
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PassKeeper',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5),
                    const SizedBox(height: 8.0),
                    AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TypewriterAnimatedText('Create Account',
                            textStyle: Theme.of(context).textTheme.headlineLarge,
                            speed: const Duration(milliseconds: 100)),
                      ],
                    ),
                    const SizedBox(height: 48.0),
                    CustomTextField(
                      controller: usernameController,
                      labelText: 'Username',
                      prefixIcon: AppIcons.user,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter a username' : null,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -1),
                    const SizedBox(height: 16.0),
                    BlocBuilder<SignUpCubit, SignUpState>(
                      builder: (context, state) {
                        return CustomTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          prefixIcon: AppIcons.lock,
                          isPassword: !state.isPasswordVisible,
                          onChanged: (password) => context
                              .read<SignUpCubit>()
                              .validatePasswordRealtime(password),
                          suffixIcon: IconButton(
                            icon: Icon(state.isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye),
                            onPressed: () => context
                                .read<SignUpCubit>()
                                .togglePasswordVisibility(),
                          ),
                          validator: validatePassword,
                        ).animate().fadeIn(delay: 700.ms).slideX(begin: 1);
                      },
                    ),
                    const SizedBox(height: 12.0),
                    const _PasswordValidationRules(),
                    const SizedBox(height: 24.0),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return CustomElevatedButton(
                          onPressed: createAccount,
                          text: 'Create Account',
                          isLoading: state is AuthLoading,
                        ).animate().fadeIn(delay: 900.ms).shake(hz: 4, );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    AuthLinkText(
                      leadingText: "Already have an account?",
                      linkText: "Sign in",
                      onPressed: () {
                        NavigationService.push(SignInScreen());
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordValidationRules extends StatelessWidget {
  const _PasswordValidationRules();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) =>
      p.hasMinLength != c.hasMinLength ||
          p.hasLetter != c.hasLetter ||
          p.hasDigit != c.hasDigit ||
          p.hasSpecialChar != c.hasSpecialChar,
      builder: (context, state) {
        if (state.hasMinLength || state.hasLetter || state.hasDigit || state.hasSpecialChar) {
          return Column(
            children: [
              _ValidationRuleItem(text: 'At least 8 characters', isValid: state.hasMinLength),
              _ValidationRuleItem(text: 'Contains letters (a-z, A-Z)', isValid: state.hasLetter),
              _ValidationRuleItem(text: 'Contains numbers (0-9)', isValid: state.hasDigit),
              _ValidationRuleItem(text: 'Contains a special character (e.g., !@#\$)', isValid: state.hasSpecialChar),
            ],
          ).animate().fadeIn(duration: 400.ms);
        }
        return const SizedBox.shrink();
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isValid ? Icons.check_circle_outline : Icons.remove_circle_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color))),
        ],
      ),
    );
  }
}