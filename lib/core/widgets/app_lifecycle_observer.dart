import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/cubit/auth_cubit/cubit.dart';
import '../../features/auth/cubit/auth_cubit/states.dart';
import '../services/settings_service.dart';


class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  Timer? _logoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logoutTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    final authCubit = context.read<AuthCubit>();

    switch (state) {
      case AppLifecycleState.resumed:
      // User returned to the app, so cancel the timer.
        _logoutTimer?.cancel();
        break;
      case AppLifecycleState.paused:
      // User left the app. Start a timer to lock the vault.
      // Only start the timer if the user is currently logged in.
        if (authCubit.state is AuthSuccess) {
          // Load the user's preferred timeout duration from settings.
          final minutes = await SettingsService().loadAutoLockTime();
          _logoutTimer = Timer(Duration(minutes: minutes), () {
            // If the timer finishes, call the logout method.
            authCubit.logout();
          });
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}