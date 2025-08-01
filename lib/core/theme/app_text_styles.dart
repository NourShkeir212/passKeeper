import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme getCustomTextTheme(Brightness brightness) {
    final Color textColor =
    brightness == Brightness.dark ? AppColors.textDark : AppColors.textLight;
    final Color labelColor = brightness == Brightness.dark
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    final TextTheme baseTextTheme = GoogleFonts.poppinsTextTheme();

    return baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge!
          .copyWith(
          fontSize: 32.0, fontWeight: FontWeight.bold, color: textColor),
      headlineSmall: baseTextTheme.headlineSmall!
          .copyWith(
          fontSize: 24.0, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: baseTextTheme.labelLarge!
          .copyWith(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
      titleMedium: baseTextTheme.titleMedium!
          .copyWith(
          fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      bodyLarge:
      baseTextTheme.bodyLarge!.copyWith(fontSize: 16, color: textColor),
      bodyMedium:
      baseTextTheme.bodyMedium!.copyWith(fontSize: 14, color: textColor),
      bodySmall:
      baseTextTheme.bodySmall!.copyWith(fontSize: 12, color: labelColor),
      labelLarge: baseTextTheme.bodyMedium!.copyWith(color: labelColor),
    );
  }
}