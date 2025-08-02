import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/database_services.dart';
import 'core/services/navigation_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/cubit/auth_cubit/cubit.dart';
import 'features/splash/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  DatabaseService db = DatabaseService();

  //await db.deleteDatabaseFile();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(DatabaseService())),
        BlocProvider(create: (context) => ThemeCubit(SettingsService())..loadTheme()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            title: 'PassKeeper',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode, // Controlled by the ThemeCubit
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}