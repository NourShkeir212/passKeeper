import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/localization/locale_cubit.dart';
import 'core/services/database_services.dart';
import 'core/services/navigation_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/app_lifecycle_observer.dart';
import 'features/auth/cubit/auth_cubit/cubit.dart';
import 'features/initial/initial_screen.dart';
import 'l10n/app_localizations.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PassKeeperApp());
}

// Renamed to PassKeeperApp for clarity
class PassKeeperApp extends StatelessWidget {
  const PassKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(DatabaseService())),
        BlocProvider(create: (context) => ThemeCubit(SettingsService())..loadTheme()),
        BlocProvider(create: (context) => LocaleCubit(SettingsService())..loadLocale()),
      ],
      child: AppLifecycleObserver(
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {

                return MaterialApp(
                  navigatorKey: NavigationService.navigatorKey,
                  debugShowCheckedModeBanner: false,
                  onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
                  locale: localeState.locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  home: const InitialScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}