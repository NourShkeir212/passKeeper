import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/secret_vault_cubit.dart';
import '../cubits/secret_vault_states.dart';
import 'secret_vault_pin_screen.dart';
import 'secret_vault_screen.dart';

class SecretVaultWrapper extends StatefulWidget {
  const SecretVaultWrapper({super.key});

  @override
  State<SecretVaultWrapper> createState() => _SecretVaultWrapperState();
}

class _SecretVaultWrapperState extends State<SecretVaultWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<SecretVaultCubit>().checkVaultStatus();
  }

  @override
  Widget build(BuildContext context) {
    // This BlocBuilder now controls which screen is visible.
    return BlocBuilder<SecretVaultCubit, SecretVaultState>(
      builder: (context, state) {
        if (state is SecretVaultLocked) {
          return SecretVaultPinScreen(isSetup: !state.isSetup);
        }
        if (state is SecretVaultUnlocked) {
          // When the state becomes Unlocked, we trigger loadItems.
          // The builder will then get a Loading and then Loaded state.
          context.read<SecretVaultCubit>().loadSecretItems();
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is SecretVaultLoaded) {
          // Once loaded, show the main screen.
          return const SecretVaultScreen();
        }

        // For Initial and Loading states
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}