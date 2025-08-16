import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:secure_accounts/core/widgets/app_title_name.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/password_validation_rules.dart';
import '../../../../l10n/app_localizations.dart';
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

// CHANGED: Converted to StatefulWidget
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // --- THE FIX ---
  // Controllers and the key are now instance variables of the State class.
  // This means they will NOT be recreated on every build.
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // It's crucial to dispose of controllers to prevent memory leaks.
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper methods are now part of the State class
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validationEnterPassword;
    }
    if (value.length < 8) {
      return AppLocalizations.of(context)!.signUpScreenPasswordRuleLength;
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[^a-zA-Z0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit || !hasSpecialChar) {
      return AppLocalizations.of(context)!.validationPasswordRules;
    }
    return null;
  }

  void createAccount() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        context: context,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessSignUp) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.feedbackAccountCreated),
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
                key: _formKey, // Use the state's form key
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: AppTitleNameWidget(fontSize: 38.0,).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5)),
                    const SizedBox(height: 30.0),
                    AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TypewriterAnimatedText(AppLocalizations.of(context)!.signUpScreenTitle,
                            textStyle: Theme.of(context).textTheme.headlineLarge,
                            speed: const Duration(milliseconds: 100)),
                      ],
                    ),
                    const SizedBox(height: 48.0),
                    CustomTextField(
                      controller: _usernameController, // Use the state's controller
                      labelText: AppLocalizations.of(context)!.signUpScreenUsernameHint,
                      prefixIcon: AppIcons.user,
                      validator: (value) =>
                      value!.isEmpty ? AppLocalizations.of(context)!.validationEnterUsername : null,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -1),
                    const SizedBox(height: 16.0),
                    BlocBuilder<SignUpCubit, SignUpState>(
                      builder: (context, state) {
                        return CustomTextField(
                          controller: _passwordController, // Use the state's controller
                          labelText: AppLocalizations.of(context)!.signUpScreenPasswordHint,
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
                    BlocBuilder<SignUpCubit, SignUpState>(
                      buildWhen: (p, c) =>
                      p.hasMinLength != c.hasMinLength ||
                          p.hasLetter != c.hasLetter ||
                          p.hasDigit != c.hasDigit ||
                          p.hasSpecialChar != c.hasSpecialChar,
                      builder: (context, state) {
                        return PasswordValidationRules(
                          hasMinLength: state.hasMinLength,
                          hasLetter: state.hasLetter,
                          hasDigit: state.hasDigit,
                          hasSpecialChar: state.hasSpecialChar,
                        );
                      },
                    ),
                    const SizedBox(height: 24.0),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return CustomElevatedButton(
                          onPressed: createAccount,
                          text: AppLocalizations.of(context)!.signUpScreenCreateButton,
                          isLoading: state is AuthLoading,
                        ).animate().fadeIn(delay: 900.ms).shake(hz: 4,);
                      },
                    ),
                    const SizedBox(height: 16.0),
                    AuthLinkText(
                      leadingText: AppLocalizations.of(context)!.signUpScreenHaveAccount,
                      linkText: AppLocalizations.of(context)!.signUpScreenLoginLink,
                      onPressed: () {
                        NavigationService.push(const SignInScreen());
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