import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/encryption_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/app_icons.dart';
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
  bool _isPasswordVisible = false;
  bool _isLoading = true;
  bool _canUseBiometrics = false;
  bool _forcePasswordUnlock = false;
  bool _decoyAccountExists = false;
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// Runs all necessary checks when the screen first loads.
  Future<void> _initializeScreen() async {
    final settingsService = SettingsService();
    final results = await Future.wait([
      BiometricService.canCheckBiometrics(),
      _checkDecoyStatus(),
      settingsService.loadBiometricPreference(),
      settingsService.loadPasswordReminderFrequency(),
      settingsService.loadBiometricUnlockCount(),
    ]);

    // --- THE FIX IS HERE: Cast the results to bool ---
    final canUseBiometrics = results[0] as bool;
    final decoyAccountExists = results[1] as bool;
    final biometricsEnabled = results[2] as bool;
    final reminderFrequency = results[3] as int;
    final unlockCount = results[4] as int;

    bool forcePassword = false;
    if (reminderFrequency > 0 && unlockCount >= reminderFrequency) {
      forcePassword = true;
    }

    if (mounted) {
      setState(() {
        // Now this '&&' operation is safe because both operands are bools
        _canUseBiometrics = canUseBiometrics && biometricsEnabled;
        _decoyAccountExists = decoyAccountExists;
        _forcePasswordUnlock = forcePassword;
        _isLoading = false;
      });

      if (_canUseBiometrics && !_forcePasswordUnlock) {
        _unlockWithBiometrics();
      }
    }
  }

  /// Checks the database to see if a decoy account is linked to the real one.
  Future<bool> _checkDecoyStatus() async {
    final realUserId = await SessionManager.getRealUserId();
    if (realUserId != null) {
      final decoyUser = await DatabaseService().getDecoyUserFor(realUserId);
      return decoyUser != null;
    }
    return false;
  }

  /// Unlocks the app with biometrics and goes to the REAL vault.
  Future<void> _unlockWithBiometrics() async {
    final l10n = AppLocalizations.of(context)!;
    final isAuthenticated = await BiometricService.authenticate(l10n.biometricPromptReason);
    if (isAuthenticated && mounted) {
      await SettingsService().incrementBiometricUnlockCount();
      SessionManager.currentSessionProfileTag = 'real';
      final masterPassword = await SecureStorageService.getMasterPassword();
      if (masterPassword != null) {
        EncryptionService().init(masterPassword);
        context.read<AccountCubit>().loadAccounts();
        context.read<CategoryCubit>().loadCategories();
        NavigationService.pushAndRemoveUntil(const HomeScreen());
      }
    }
  }

  /// Attempts to unlock with the entered password (could be real or decoy).
  void _unlockWithPassword() {
    FocusScope.of(context).unfocus();
    if (_passwordController.text.isEmpty) return;
    SettingsService().resetBiometricUnlockCount();
    context.read<AuthCubit>().unlockWithPassword(_passwordController.text);
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

                // Conditionally show the biometric button
                if (_canUseBiometrics && !_forcePasswordUnlock) ...[
                  OutlinedButton.icon(
                    onPressed: _unlockWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.unlockButton),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
                  if(!_forcePasswordUnlock)...[
                  const SizedBox(height: 24),
                  CustomText(l10n.lockScreenOr),
                  const SizedBox(height: 24),
                  ],
                  CustomTextField(
                    controller: _passwordController,
                    labelText: l10n.lockScreenPasswordUnlock,
                    prefixIcon: Icons.lock_outline,
                    isPassword: _isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye,
                      ),
                      onPressed: () {
                        // Update the state to toggle visibility
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: _unlockWithPassword,
                      text: l10n.lockScreenUnlockButton,
                    ),
                  ),
              ],
            ).animate().fadeIn(),
          ),
        ),
      ),
    );
  }
}