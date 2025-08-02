import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/database_services.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/widgets/custom_text.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import '../change_password/change_password_screen.dart';
import '../home/cubit/account_cubit/cubit.dart';
import '../home/cubit/category_cubit/cubit.dart';
import '../manage_categories/manage_categories_screen.dart';
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
              NavigationService.pushAndRemoveUntil(const SignInScreen());
            }
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsExporting || state is SettingsImporting) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => PopScope(
                  canPop: false,
                  child: AlertDialog(
                    content: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 20),
                        Text(state is SettingsExporting
                            ? "Exporting..."
                            : "Importing..."),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is SettingsExportSuccess ||
                state is SettingsImportSuccess) {
              Navigator.of(context).pop(); // Close loading dialog
              if (state is SettingsImportSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ));
              }
            } else if (state is SettingsExportFailure ||
                state is SettingsImportFailure) {
              Navigator.of(context).pop(); // Close loading dialog
              final error = state is SettingsExportFailure
                  ? state.error
                  : (state as SettingsImportFailure).error;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Operation failed: $error"),
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
                              icon: Icon(AppIcons.sun),
                              label: Text('Light'),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: Icon(AppIcons.moon),
                              label: Text('Dark'),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: Icon(AppIcons.auto),
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
                            WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
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
                  const _SettingsGroupTitle(title: "Customization"), // New or existing group
                  ListTile(
                    title: const Text("Manage Categories"),
                    leading: const Icon(AppIcons.category),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => MultiBlocProvider( // <-- USE MultiBlocProvider
                          providers: [
                            // Provide the existing CategoryCubit
                            BlocProvider.value(
                              value: context.read<CategoryCubit>(),
                            ),
                            // ALSO provide the existing AccountCubit
                            BlocProvider.value(
                              value: context.read<AccountCubit>(),
                            ),
                          ],
                          child: const ManageCategoriesScreen(),
                        ),
                      ));
                    },
                  ),

                // ... Security section
                  const Divider(),
                  const _SettingsGroupTitle(title: "Security"),
                  SwitchListTile(
                    title: const Text("Enable Biometric Lock"),
                    subtitle: const Text(
                        "Use fingerprint/Face ID to unlock the app."),
                    value: settingsState.isBiometricEnabled,
                    onChanged: (val) =>
                        context.read<SettingsCubit>().toggleBiometrics(val),
                  ),
                  ListTile(
                    title: const Text("Change Password"),
                    leading: const Icon(AppIcons.password),
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
                  const _SettingsGroupTitle(title: "Data Management"),
                  ListTile(
                    title: const Text("Import from Excel"),
                    subtitle:
                    const Text("Restore accounts from a backup file."),
                    leading: const Icon(AppIcons.import),
                    onTap: () {
                      context.read<SettingsCubit>().importData(
                        accountCubit: context.read<AccountCubit>(),
                        categoryCubit: context.read<CategoryCubit>(),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text("Export to Excel"),
                    subtitle: const Text(
                        "Save a copy of your accounts to a file."),
                    leading: const Icon(AppIcons.export),
                    onTap: () {
                      context.read<SettingsCubit>().exportData();
                    },
                  ),
                  const Divider(),
                  const _SettingsGroupTitle(title: "Account"),
                  ListTile(
                    title: Text("Logout",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    leading: Icon(AppIcons.logout,
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