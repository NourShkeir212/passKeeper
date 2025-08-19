import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/services/database_services.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/session_manager.dart';
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
import '../create_decoy/create_decoy_screen.dart';
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
                        Text(
                          state is SettingsExporting
                              ? l10n.feedbackExporting
                              : l10n.feedbackImporting,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is SettingsExportSuccess ||
                state is SettingsImportSuccess) {
              Navigator.of(context).pop();
              if (state is SettingsImportSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else if (state is SettingsExportFailure ||
                state is SettingsImportFailure) {
              Navigator.of(context).pop();
              final error = state is SettingsExportFailure
                  ? state.error
                  : (state as SettingsImportFailure).error;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.errorExportFailed(error)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsScreenTitle)),
        body: FutureBuilder<String>(
          future: SessionManager.getActiveProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final activeProfile = snapshot.data!;
            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                if (settingsState is SettingsInitial) {
                  return ListView(
                    children: [
                      _buildAppearanceSection(context, l10n),
                      _buildLanguageSection(context, l10n),
                      _buildCustomizationSection(context, l10n),
                      _buildSecuritySection(context, l10n, settingsState),
                      _buildDataSection(context, l10n),
                      _buildAboutSection(context, l10n),
                      _buildDecoySection(
                        context,
                        l10n,
                        settingsState,
                        activeProfile,
                      ),
                      _buildAccountSection(context, l10n),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  // --- REFACTORED SECTIONS ---

  Widget _buildAppearanceSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsGroupTitle(title: l10n.settingsAppearance),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return SegmentedButton<ThemeMode>(
                segments: <ButtonSegment<ThemeMode>>[
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
                  context.read<ThemeCubit>().setTheme(newSelection.first);
                },

                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  visualDensity: VisualDensity.compact,

                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2);
                    }

                    return null;
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsGroupTitle(title: l10n.settingsLanguage),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              // --- FIX IS HERE: Wrap with SizedBox ---
              return SizedBox(
                width: double.infinity, // This makes the child take the full width
                child: SegmentedButton<String>(
                  segments: <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text(l10n.settingsLangEnglish),
                    ),
                    ButtonSegment<String>(
                      value: 'ar',
                      label: Text(l10n.settingsLangArabic),
                    ),
                    ButtonSegment<String>(
                      value: 'system',
                      label: Text(l10n.settingsLangAuto),
                    ),
                  ],
                  selected: <String>{
                    localeState.locale?.languageCode ?? 'system',
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2);
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _SettingsGroupTitle(title: l10n.manageCategoriesTitle),
        ListTile(
          title: Text(l10n.manageCategoriesTitle),
          leading: const Icon(AppIcons.category),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<CategoryCubit>()),
                    BlocProvider.value(value: context.read<AccountCubit>()),
                  ],
                  child: const ManageCategoriesScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsInitial settingsState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _SettingsGroupTitle(title: l10n.settingsSecurity),
        SwitchListTile(
          title: Text(l10n.settingsBiometricTitle),
          subtitle: Text(l10n.settingsBiometricSubtitle),
          value: settingsState.isBiometricEnabled,
          onChanged: (val) =>
              context.read<SettingsCubit>().toggleBiometrics(val),
        ),
        ListTile(
          leading: const Icon(AppIcons.timer),
          title: Text(l10n.settingsAutoLockTitle),
          trailing: DropdownButton<int>(
            value: settingsState.autoLockMinutes,
            items: [1, 5, 15, 30]
                .map(
                  (minutes) => DropdownMenuItem(
                    value: minutes,
                    child: Text(l10n.settingsAutoLockMinutes(minutes)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().changeAutoLockTime(value);
              }
            },
          ),
        ),
        ListTile(
          title: Text(l10n.changePasswordTitle),
          leading: const Icon(AppIcons.password),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<SettingsCubit>()),
                    BlocProvider.value(value: context.read<AccountCubit>()),
                  ],
                  child: const ChangePasswordScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _SettingsGroupTitle(title: l10n.settingsDataManagement),
        ListTile(
          title: Text(l10n.settingsImportTitle),
          subtitle: Text(l10n.settingsImportSubtitle),
          leading: const Icon(AppIcons.import),
          onTap: () async {
            final authCubit = context.read<AuthCubit>();
            final settingsCubit = context.read<SettingsCubit>();
            final encryptionService = EncryptionService();

            if (!encryptionService.isInitialized) {
              final password = await showMasterPasswordDialog(context);
              if (password == null || password.isEmpty) return;
              final success = await authCubit.verifyMasterPassword(password);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.errorIncorrectPassword),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
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
          title: Text(l10n.settingsExportTitle),
          subtitle: Text(l10n.settingsExportSubtitle),
          leading: const Icon(AppIcons.export),
          onTap: () => context.read<SettingsCubit>().exportData(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _SettingsGroupTitle(title: l10n.aboutTitle),
        ListTile(
          title: Text(l10n.aboutScreenTitle),
          leading: const Icon(AppIcons.shield),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildDecoySection(BuildContext context, AppLocalizations l10n,
      SettingsInitial settingsState, String activeProfile)
  {
    // Only show this section if the user is in their "real" account
    if (activeProfile != 'real') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _SettingsGroupTitle(title: l10n.decoyVaultTitle),

        if (settingsState.decoyUser != null) ...[
          // --- UI to show if decoy account EXISTS ---
          ListTile(
            leading: const Icon(AppIcons.eyeSlash),
            title: Text(l10n.decoyVaultActive),
            subtitle: Text("${AppLocalizations.of(context)!.decoyAccountUserName} : ${settingsState.decoyUser!.username}"),
          ),
          ListTile(
            title: Text(l10n.decoyVaultReset,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            leading: Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.decoyResetConfirmTitle),
                  content: Text(l10n.decoyResetConfirmContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.dialogCancel),
                    ),
                    TextButton(
                      onPressed: () {
                        // Close the confirmation dialog
                        Navigator.of(dialogContext).pop();
                        // Call the reset method from the cubit
                        context.read<SettingsCubit>().resetDecoyVault();
                      },
                      child: Text(
                        l10n.decoyResetButton,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ] else ...[
          ListTile(
            leading: const Icon(AppIcons.add),
            title: Text(l10n.decoyVaultCreate),
            subtitle: Text(l10n.decoyVaultSubtitle),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: context.read<AuthCubit>(),
                    ),
                    BlocProvider.value(
                      value: context.read<SettingsCubit>(),
                    ),
                  ],
                  child: const CreateDecoyScreen(),
                ),
              ));
            },
          )
        ],
      ],
    );
  }


  Widget _buildAccountSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _SettingsGroupTitle(title: l10n.settingsAccount),
        ListTile(
          title: Text(
            l10n.settingsLogout,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          leading: Icon(
            AppIcons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
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
                      Navigator.of(dialogContext).pop();
                      context.read<AuthCubit>().logout();
                    },
                    child: Text(
                      l10n.dialogLogoutButton,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
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
          leading: Icon(
            Iconsax.profile_delete,
            color: Theme.of(context).colorScheme.error,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<SettingsCubit>()),
                    BlocProvider.value(value: context.read<AuthCubit>()),
                  ],
                  child: const DeleteAccountScreen(),
                ),
              ),
            );
          },
        ),
      ],
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
