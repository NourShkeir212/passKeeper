import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/localization/locale_cubit.dart';
import 'core/services/database_services.dart';
import 'core/services/navigation_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/cubit/auth_cubit/cubit.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(DatabaseService())),
        BlocProvider(create: (context) =>
        ThemeCubit(SettingsService())
          ..loadTheme()),
        BlocProvider(create: (_) =>
        LocaleCubit(SettingsService())
          ..loadLocale()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return MaterialApp(
                  localizationsDelegates: AppLocalizations
                      .localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: localeState.locale,
                  onGenerateTitle: (context) {
                    return AppLocalizations.of(context)!.appTitle;
                  },
                  navigatorKey: NavigationService.navigatorKey,
                  title: 'PassKeeper',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  home: const SplashScreen(),
                );
              }
          );
        },
      ),
    );
  }
}