import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/features/auth/screens/sign_in/sign_in_screen.dart';

import '../../core/services/navigation_service.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Listen for the logged-out state to navigate away
        if (state is AuthLoggedOut) {
          NavigationService.pushAndRemoveUntil(const SignInScreen());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                // Call the logout method from the AuthCubit
                context.read<AuthCubit>().logout();
              },
            )
          ],
        ),
        body: Center(
          child: Text(
            'Welcome to PassKeeper!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}