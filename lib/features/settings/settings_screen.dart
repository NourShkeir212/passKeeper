import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/database_services.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/widgets/custom_text.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import '../change_password/change_password_screen.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      SettingsCubit(SettingsService(), DatabaseService())..loadSettings(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              // Navigate to login screen after logout
              NavigationService.pushAndRemoveUntil(const SignInScreen());
            }
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsExporting) {
              // Show a loading dialog during export
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const PopScope(
                  canPop: false,
                  child: AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("Exporting..."),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is SettingsExportSuccess) {
              Navigator.of(context).pop(); // Close loading dialog
            } else if (state is SettingsExportFailure) {
              Navigator.of(context).pop(); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Export failed: ${state.error}"),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            if (settingsState is SettingsInitial) {
              return ListView(
                children: [
                  // --- Theme Section ---
                  const _SettingsGroupTitle(title: "Appearance"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        return SegmentedButton<ThemeMode>(
                          segments: const <ButtonSegment<ThemeMode>>[
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: Icon(Icons.wb_sunny_outlined),
                              label: Text('Light'),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.nightlight_outlined),
                              label: Text('Dark'),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_outlined),
                              label: Text('Auto'),
                            ),
                          ],
                          selected: <ThemeMode>{themeState.themeMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            context
                                .read<ThemeCubit>()
                                .setTheme(newSelection.first);
                          },
                          style: ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2);
                                }
                                return null;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),

                  // --- Security Section ---
                  const _SettingsGroupTitle(title: "Security"),
                  SwitchListTile(
                    title: const Text("Enable Biometric Lock"),
                    subtitle:
                    const Text("Use fingerprint/Face ID to unlock the app."),
                    value: settingsState.isBiometricEnabled,
                    onChanged: (val) =>
                        context.read<SettingsCubit>().toggleBiometrics(val),
                  ),
                  ListTile(
                    title: const Text("Change Password"),
                    leading: const Icon(Icons.password),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<SettingsCubit>(),
                              child: const ChangePasswordScreen(),
                            ),
                          ));
                    },
                  ),
                  const Divider(),

                  // --- Data Management Section ---
                  const _SettingsGroupTitle(title: "Data Management"),
                  ListTile(
                    title: const Text("Export to Excel"),
                    subtitle:
                    const Text("Save a copy of your accounts to a file."),
                    leading: const Icon(Icons.upload_file),
                    onTap: () {
                      context.read<SettingsCubit>().exportData();
                    },
                  ),
                  const Divider(),

                  // --- Account Section ---
                  const _SettingsGroupTitle(title: "Account"),
                  ListTile(
                    title: Text("Logout",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    leading: Icon(Icons.logout,
                        color: Theme.of(context).colorScheme.error),
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