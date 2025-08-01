import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme getCustomTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.dark ? AppColors.textDark : AppColors.textLight;
    final Color labelColor = brightness == Brightness.dark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;

    // Change from Cairo to Poppins
    final TextTheme baseTextTheme = GoogleFonts.poppinsTextTheme();

    return baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleLarge: baseTextTheme.labelLarge!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        fontSize: 16,
        color: textColor,
      ),
      labelLarge: baseTextTheme.bodyMedium!.copyWith(
        color: labelColor,
      ),
    );
  }
}