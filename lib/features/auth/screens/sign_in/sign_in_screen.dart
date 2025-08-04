import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/home_screen.dart';
import '../../cubit/auth_cubit/cubit.dart';
import '../../cubit/auth_cubit/states.dart';
import '../../widgets/auth_link_text.dart';
import '../sign_up/sign_up_screen.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        context: context,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
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
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- UI remains the same here ---
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 8.0),
                    AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          AppLocalizations.of(context)!.loginScreenWelcome,
                          textStyle: Theme.of(context).textTheme.headlineLarge,
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48.0),
                    CustomTextField(
                      controller: _usernameController,
                      labelText: AppLocalizations.of(context)!.loginScreenUsernameHint,
                      prefixIcon: AppIcons.user,
                      validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.validationEnterUsername : null,
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 16.0),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        return CustomTextField(
                          controller: _passwordController,
                          labelText: AppLocalizations.of(context)!.loginScreenPasswordHint,
                          prefixIcon: AppIcons.lock,
                          isPassword: !state.isPasswordVisible,
                          validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.validationEnterPassword : null,
                          suffixIcon: IconButton(
                            icon: Icon(state.isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye),
                            onPressed: () => context.read<LoginCubit>().togglePasswordVisibility(),
                          ),
                        ).animate().fadeIn(delay: 700.ms);
                      },
                    ),

                    const SizedBox(height: 24.0),

                    // --- USING THE REUSABLE WIDGET ---
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return CustomElevatedButton(
                          onPressed: _login,
                          text: AppLocalizations.of(context)!.loginScreenLoginButton,
                          isLoading: state is AuthLoading,
                        ).animate().fadeIn(delay: 900.ms);
                      },
                    ),

                    const SizedBox(height: 16.0),
                    AuthLinkText(
                      leadingText:AppLocalizations.of(context)!.loginScreenNoAccount,
                      linkText: AppLocalizations.of(context)!.loginScreenSignUpLink,
                      onPressed: () {
                      NavigationService.push(SignUpScreen());
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