import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/core/theme/app_icons.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/widgets/app_title_name.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/cubit/account_cubit/cubit.dart';
import '../../../home/cubit/category_cubit/cubit.dart';
import '../../../home/home_screen.dart';
import '../../cubit/auth_cubit/cubit.dart';
import '../../cubit/auth_cubit/states.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _decoyAccountExists = false;

  @override
  void initState() {
    super.initState();
    _checkDecoyStatus();
  }

  /// Checks the database to see if a decoy account is linked to the real one.
  Future<void> _checkDecoyStatus() async {
    final realUserId = await SessionManager.getRealUserId();
    if (realUserId != null) {
      final decoyUser = await DatabaseService().getDecoyUserFor(realUserId);
      if (mounted) {
        setState(() {
          _decoyAccountExists = (decoyUser != null);
          _isLoading = false;
        });
      }
    } else {
      // Should not happen, but handle it gracefully
      if (mounted) setState(() => _isLoading = false);
    }
  }
  /// Unlocks the app with biometrics and goes to the REAL vault.
  Future<void> _unlockWithBiometrics() async {
    final l10n = AppLocalizations.of(context)!;
    final isAuthenticated = await BiometricService.authenticate(l10n.biometricPromptReason);

    if (isAuthenticated && mounted) {
      // This flow is only for the REAL vault, so we set the profile to 'real'
      SessionManager.currentSessionProfileTag = 'real';

        // Reload data for the real profile
        context.read<AccountCubit>().loadAccounts();
        context.read<CategoryCubit>().loadCategories();

        NavigationService.pushAndRemoveUntil(const HomeScreen());
    }
  }

  /// Attempts to unlock the DECOY vault with the entered password.
  void _unlockWithDecoyPassword() {
    FocusScope.of(context).unfocus();
    if (_passwordController.text.isEmpty) return;

    context.read<AuthCubit>().unlockWithPassword(_passwordController.text,context);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {

          context.read<AccountCubit>().loadAccounts();
          context.read<CategoryCubit>().loadCategories();

          NavigationService.pushAndRemoveUntil(const HomeScreen());
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppTitleNameWidget(fontSize: 34),
                const SizedBox(height: 16),
                CustomText(l10n.lockScreenTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 48),

                OutlinedButton.icon(
                  onPressed: _unlockWithBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.unlockButton),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),

                // --- THE FIX IS HERE ---
                // Only show the password option if a decoy account exists
                if (_decoyAccountExists) ...[
                  const SizedBox(height: 24),
                  CustomText(l10n.lockScreenOr),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: l10n.loginScreenPasswordHint,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: _unlockWithDecoyPassword,
                      text: l10n.lockScreenUnlockButton,
                    ),
                  ),
                ]
              ],
            ).animate().fadeIn(),
          ),
        ),
      ),
    );
  }
}