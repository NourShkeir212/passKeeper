import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../l10n/app_localizations.dart';
import '../cubits/secret_vault_cubit.dart';
import '../cubits/secret_vault_states.dart';
class SecretVaultPinScreen extends StatefulWidget {
  final bool isSetup;
  const SecretVaultPinScreen({super.key, required this.isSetup});

  @override
  State<SecretVaultPinScreen> createState() => _SecretVaultPinScreenState();
}

class _SecretVaultPinScreenState extends State<SecretVaultPinScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  bool _hasError = false;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- Modern Pin Theme ---
    final defaultPinTheme = PinTheme(
      width: 56, height: 60,
      textStyle: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.onSurface),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Theme
            .of(context)
            .colorScheme
            .primary, width: 2),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetup ? l10n.secretVaultPinScreenSetupTitle : l10n.secretVaultPinScreenEnterTitle),
      ),
      body: BlocConsumer<SecretVaultCubit, SecretVaultState>(
        listener: (context, state) {
          if (state is SecretVaultError) {
            // When an error occurs, set the error state and clear the controller
            setState(() => _hasError = true);
            pinController.clear();
            focusNode.requestFocus();
          }
        },
        builder: (context, state) {
          if (state is SecretVaultLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.shield, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  CustomText(
                    widget.isSetup ? l10n.secretVaultPinScreenSetPinHeader : l10n.secretVaultPinScreenUnlockHeader,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    l10n.secretVaultPinScreenInstruction,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Pinput(
                    length: 4,
                    controller: pinController,
                    focusNode: focusNode,
                    obscureText: true,
                    autofocus: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    // --- THE FIX IS HERE ---
                    forceErrorState: _hasError,
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    errorBuilder: (errorText, pin) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          l10n.errorIncorrectPin,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                        ),
                      );
                    },
                    onChanged: (pin) {
                      // Clear the error state as the user types a new PIN
                      if (_hasError) {
                        setState(() => _hasError = false);
                      }
                    },
                    onCompleted: (pin) {
                      if (widget.isSetup) {
                        context.read<SecretVaultCubit>().setupVault(pin);
                      } else {
                        context.read<SecretVaultCubit>().unlockVault(pin);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}