import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/database_services.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/widgets/custom_text.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../change_password/change_password_screen.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(SettingsService(), DatabaseService())..loadSettings(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          if (settingsState is SettingsInitial) {
            return ListView(
              children: [
                // --- Theme Section ---
                _SettingsGroupTitle(title: "Appearance"),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text("System Default"),
                          value: ThemeMode.system,
                          groupValue: themeState.themeMode,
                          onChanged: (val) => context.read<ThemeCubit>().setTheme(val!),
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Light"),
                          value: ThemeMode.light,
                          groupValue: themeState.themeMode,
                          onChanged: (val) => context.read<ThemeCubit>().setTheme(val!),
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Dark"),
                          value: ThemeMode.dark,
                          groupValue: themeState.themeMode,
                          onChanged: (val) => context.read<ThemeCubit>().setTheme(val!),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(),
                // --- Security Section ---
                _SettingsGroupTitle(title: "Security"),
                SwitchListTile(
                  title: const Text("Enable Biometric Lock"),
                  subtitle: const Text("Use fingerprint/Face ID to unlock the app."),
                  value: settingsState.isBiometricEnabled,
                  onChanged: (val) => context.read<SettingsCubit>().toggleBiometrics(val),
                ),
                ListTile(
                  title: const Text("Change Password"),
                  leading: const Icon(Icons.password),
                  onTap: () {
                    // Navigate while providing the existing cubit
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<SettingsCubit>(),
                        child: const ChangePasswordScreen(),
                      ),
                    ));
                  },
                ),
                const Divider(),

                // --- NEW: Account Section ---
                const _SettingsGroupTitle(title: "Account"),
                ListTile(
                  title: Text(
                    "Logout",
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                  onTap: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _SettingsGroupTitle extends StatelessWidget {
  final String title;
  const _SettingsGroupTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: CustomText(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}