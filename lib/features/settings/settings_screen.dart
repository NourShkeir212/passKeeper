import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/services/database_services.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/master_password_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../about_screen/about_screen.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import '../change_password/change_password_screen.dart';
import '../delete_account/delete_account_screen.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                            ? l10n.feedbackExporting
                            : l10n.feedbackImporting),
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
                content: Text(l10n.errorExportFailed(error.toString())),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title:  Text(l10n.settingsScreenTitle)),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            if (settingsState is SettingsInitial) {
              return ListView(
                children: [
                   _SettingsGroupTitle(title:l10n.settingsAppearance),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        return SegmentedButton<ThemeMode>(
                          segments:  <ButtonSegment<ThemeMode>>[
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: Icon(AppIcons.sun),
                              label: Text(l10n.settingsThemeLight),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: Icon(AppIcons.moon),
                              label: Text(l10n.settingsThemeDark),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: Icon(AppIcons.auto),
                              label: Text(l10n.settingsThemeSystem),
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
                  // --- Language Section ---
                   _SettingsGroupTitle(title: l10n.settingsLanguage),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        return SegmentedButton<String>(
                          segments:  <ButtonSegment<String>>[
                            ButtonSegment<String>(value: 'en', label: Text(l10n.settingsLangEnglish)),
                            ButtonSegment<String>(value: 'ar', label: Text(l10n.settingsLangArabic)),
                            ButtonSegment<String>(value: 'system', label: Text(l10n.settingsLangAuto), icon: Icon(AppIcons.auto)),
                          ],
                          // Determine the selected segment
                          selected: <String>{
                            localeState.locale?.languageCode ?? 'system'
                          },
                          style: ButtonStyle(
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
                          onSelectionChanged: (Set<String> newSelection) {
                            final selection = newSelection.first;
                            if (selection == 'system') {
                              context.read<LocaleCubit>().clearLocale();
                            } else {
                              context.read<LocaleCubit>().setLocale(Locale(selection));
                            }
                          },
                          // ... styling from theme switcher ...
                        );
                      },
                    ),
                  ),
                  const Divider(),
                   _SettingsGroupTitle(title: l10n.manageCategoriesTitle), // New or existing group
                  ListTile(
                    title:  Text(l10n.accountFormCategoryHint),
                    leading: const Icon(AppIcons.category),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
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
                   _SettingsGroupTitle(title: l10n.settingsSecurity),
                  SwitchListTile(
                    title:  Text(l10n.settingsBiometricTitle),
                    subtitle:  Text(
                        l10n.settingsBiometricSubtitle),
                    value: settingsState.isBiometricEnabled,
                    onChanged: (val) =>
                        context.read<SettingsCubit>().toggleBiometrics(val),
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.timer),
                    title:  Text(l10n.settingsAutoLockTitle,maxLines: 3,),
                    trailing: DropdownButton<int>(
                      underline: SizedBox.shrink(),
                      value: settingsState.autoLockMinutes,
                      items:  [
                        DropdownMenuItem(value: 1, child: Text(l10n.settingsAutoLockMinutes(1))),
                        DropdownMenuItem(value: 5, child: Text(l10n.settingsAutoLockMinutes(5))),
                        DropdownMenuItem(value: 10, child: Text(l10n.settingsAutoLockMinutes(10))),
                        DropdownMenuItem(value: 15, child: Text(l10n.settingsAutoLockMinutes(15))),
                        DropdownMenuItem(value: 30, child: Text(l10n.settingsAutoLockMinutes(30))),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsCubit>().changeAutoLockTime(value);
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title:  Text(l10n.settingsChangePassword),
                    leading: const Icon(AppIcons.password),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            // Provide the existing cubits to the ChangePasswordScreen
                            BlocProvider.value(value: context.read<SettingsCubit>()),
                            BlocProvider.value(value: context.read<AccountCubit>()),
                          ],
                          child: const ChangePasswordScreen(),
                        ),
                      ));
                    },
                  ),
                  const Divider(),
                   // --- DATA MANAGEMENT ---
                   _SettingsGroupTitle(title: l10n.settingsDataManagement),
                  ListTile(
                    title:  Text(l10n.settingsImportTitle),
                    subtitle:  Text(l10n.settingsImportSubtitle),
                    leading: const Icon(AppIcons.import),
                    onTap: () async { // Make the onTap async
                      final authCubit = context.read<AuthCubit>();
                      final settingsCubit = context.read<SettingsCubit>();
                      final encryptionService = EncryptionService();

                      // Check if the vault is unlocked
                      if (!encryptionService.isInitialized) {
                        final password = await showMasterPasswordDialog(
                          context,
                          title: l10n.dialogUnlockToImportTitle,
                          content: l10n.dialogUnlockToImportContent,
                        );
                        if (password == null || password.isEmpty) return; // User cancelled

                        final success = await authCubit.verifyMasterPassword(password);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(l10n.errorIncorrectPassword), backgroundColor: Colors.red),
                          );
                          return; // Stop on failure
                        }
                      }

                      settingsCubit.importData(
                        accountCubit: context.read<AccountCubit>(),
                        categoryCubit: context.read<CategoryCubit>(),
                        context: context,
                      );
                    },
                  ),
                  ListTile(
                    title:  Text(l10n.settingsExportTitle),
                    subtitle:  Text(
                        l10n.settingsExportSubtitle),
                    leading: const Icon(AppIcons.export),
                    onTap: () {
                      context.read<SettingsCubit>().exportData();
                    },
                  ),
                  const Divider(),
                   // --- ABOUT ---
                   _SettingsGroupTitle(title: l10n.aboutTitle),
                  ListTile(
                    title:  Text(l10n.aboutScreenTitle),
                    leading: const Icon(AppIcons.shield), // Or Icons.info_outline
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                    },
                  ),

                  const Divider(),
                   // --- SETTINGS ---
                   _SettingsGroupTitle(title: l10n.settingsAccount),
                  ListTile(
                    title: Text(l10n.settingsLogout,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    leading: Icon(AppIcons.logout,
                        color: Theme.of(context).colorScheme.error),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.dialogConfirmLogoutTitle),
                          content: Text(l10n.dialogConfirmLogoutContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text(l10n.dialogCancel),
                            ),
                            TextButton(
                              onPressed: () {
                                // Close the dialog first
                                Navigator.of(dialogContext).pop();
                                // Then call the logout method
                                context.read<AuthCubit>().logout();
                              },
                              child: Text(
                                l10n.dialogLogoutButton,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      l10n.settingsDeleteAllData,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    leading: Icon(Iconsax.profile_delete, color: Theme.of(context).colorScheme.error),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<SettingsCubit>()),
                            BlocProvider.value(value: context.read<AuthCubit>()),
                          ],
                          child: const DeleteAccountScreen(),
                        ),
                      ));
                    },
                  ),
                ],
              );
            }
            return SizedBox.shrink();
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