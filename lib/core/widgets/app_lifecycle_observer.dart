import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/cubit/auth_cubit/cubit.dart';
import '../../features/auth/cubit/auth_cubit/states.dart';


class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> with WidgetsBindingObserver {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final authCubit = context.read<AuthCubit>();

    switch (state) {
      case AppLifecycleState.resumed:
        _logoutTimer?.cancel();
        break;
      case AppLifecycleState.paused:
      // Only start the timer if the user is actually logged in
        if (authCubit.state is AuthSuccess) {
          _logoutTimer = Timer(const Duration(minutes: 5), () {
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