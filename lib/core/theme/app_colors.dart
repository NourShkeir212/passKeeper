import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  // --- DARK THEME --- ///
  /// Dark background, almost black with a hint of blue
  static const Color backgroundDark = Color(0xFF1A1A24);

  /// Cards and primary surfaces
  static const Color cardDark = Color(0xFF2D2D82);

  /// Primary color for highlights, links,
  static const Color primaryDark = Color(0xFF41CFD7);

  /// Accent color for buttons and calls to action (Bright Gold)
  static const Color accentDark = Color(0xFFFFC107);

  /// Text colors for high and medium emphasis
  static const Color textDark = Colors.white;
  static const Color textDarkSecondary = Colors.white70;


  // --- LIGHT THEME --- ///
  /// Standard light gray background
  static const Color backgroundLight = Color(0xFFF5F5F7);

  /// Cards and primary surfaces
  static const Color cardLight = Colors.white;

  /// Primary color for branding and text
  static const Color primaryLight = Color(0xFF2D2D82);

  /// Lighter accent color for UI elements
  static const Color accentLight = Color(0xFF41CFD7);

  /// Text colors for high and medium emphasis
  static const Color textLight = Color(0xFF1D1D1F);
  static const Color textLightSecondary = Colors.black54;


  // --- SHARED COLORS --- ///
  static const Color white = Colors.white;
  static const Color gold = Color(0xFFFFC107);
}