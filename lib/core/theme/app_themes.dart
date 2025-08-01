import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      background: AppColors.backgroundLight,
      error: Colors.redAccent,
    ),
    textTheme: AppTextStyles.getCustomTextTheme(Brightness.light),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textLight,
      titleTextStyle: AppTextStyles.getCustomTextTheme(Brightness.light).titleLarge?.copyWith(color: AppColors.textLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        textStyle: AppTextStyles.getCustomTextTheme(Brightness.light).titleLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: AppTextStyles.getCustomTextTheme(Brightness.light).labelLarge,
      filled: true,
      fillColor: AppColors.cardLight,
      prefixIconColor: AppColors.textLightSecondary,
      suffixIconColor: AppColors.textLightSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.accentDark,
      background: AppColors.backgroundDark,
      error: Colors.red,
    ),
    textTheme: AppTextStyles.getCustomTextTheme(Brightness.dark),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textDark,
      titleTextStyle: AppTextStyles.getCustomTextTheme(Brightness.dark).titleLarge?.copyWith(color: AppColors.textDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        textStyle: AppTextStyles.getCustomTextTheme(Brightness.dark).titleLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: AppTextStyles.getCustomTextTheme(Brightness.dark).labelLarge,
      filled: true,
      fillColor: AppColors.cardDark,
      prefixIconColor: AppColors.textDarkSecondary,
      suffixIconColor: AppColors.textDarkSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
    ),
  );
}