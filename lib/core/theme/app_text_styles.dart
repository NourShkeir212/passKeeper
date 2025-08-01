import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();


  static TextTheme getCustomTextTheme(Brightness brightness) {

    final Color textColor = brightness == Brightness.dark ? AppColors.white : AppColors.textLight;
    final Color labelColor = brightness == Brightness.dark ? AppColors.white.withOpacity(0.7) : AppColors.lightGrey;

    final TextTheme baseTextTheme = GoogleFonts.cairoTextTheme();

    return baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleLarge: baseTextTheme.labelLarge!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.white, // Button text is always white in our design
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        fontSize: 16,
        color: textColor,
      ),
      labelLarge: baseTextTheme.bodyMedium!.copyWith(
        color: labelColor, // For input field labels
      ),
    );
  }
}