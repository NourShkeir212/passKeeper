import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/navigation_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_icons.dart';
import '../../l10n/app_localizations.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/lock_screen/lock_screen.dart';
import '../auth/screens/on_boarding_screen/on_boarding_screen.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import '../home/home_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Check if onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    // Remove the native initial screen

    if (!onboardingCompleted) {
      // If not completed, go to OnboardingScreen
      NavigationService.pushReplacement(const OnboardingScreen());
    } else {
      // If completed, proceed with the normal session check
      if (mounted) {
        context.read<AuthCubit>().checkSession();
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state)async {
        if (state is AuthSuccess)  {
          // Check if biometrics are enabled BEFORE navigating
          final settingsService = SettingsService();
          final biometricsEnabled = await settingsService.loadBiometricPreference();
          if (biometricsEnabled) {
            NavigationService.pushReplacement(const LockScreen());
          } else {
            // If disabled, go straight to home
            NavigationService.pushAndRemoveUntil(const HomeScreen());
          }
        } else if (state is AuthLoggedOut) {
          NavigationService.pushReplacement(const SignInScreen());
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Icon(
                AppIcons.shield,
                size: 100,
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 900.ms, curve: Curves.easeIn),
    );
  }
}