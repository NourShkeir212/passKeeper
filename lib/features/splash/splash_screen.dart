import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/navigation_service.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check for an active session after a short delay to allow animation to be seen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AuthCubit>().checkSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          NavigationService.pushAndRemoveUntil(const HomeScreen());
        } else if (state is AuthLoggedOut) {
          NavigationService.pushAndRemoveUntil(const SignInScreen());
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Icon(
                Icons.shield_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'PassKeeper',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
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