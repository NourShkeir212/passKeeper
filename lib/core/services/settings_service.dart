import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeKey = 'themeMode';
  static const _biometricKey = 'biometricEnabled';
  static const _autoLockKey = 'autoLockMinutes';
  static const _passwordReminderKey = 'passwordReminderFrequency';
  static const _biometricUnlockCountKey = 'biometricUnlockCount';

  Future<void> savePasswordReminderFrequency(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_passwordReminderKey, count);
  }

  Future<int> loadPasswordReminderFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 5 times. 0 means never ask.
    return prefs.getInt(_passwordReminderKey) ?? 5;
  }

  // --- NEW: Biometric Unlock Counter ---
  Future<void> incrementBiometricUnlockCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = await loadBiometricUnlockCount();
    await prefs.setInt(_biometricUnlockCountKey, currentCount + 1);
  }

  Future<int> loadBiometricUnlockCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_biometricUnlockCountKey) ?? 0;
  }

  Future<void> resetBiometricUnlockCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_biometricUnlockCountKey, 0);
  }

  // --- Theme ---
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere((e) => e.name == themeName);
  }

  // --- Biometrics ---
  Future<void> saveBiometricPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, isEnabled);
  }

  Future<bool> loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true for security
    return prefs.getBool(_biometricKey) ?? true;
  }


// --- Language ---
  static const _localeKey = 'languageCode';

  Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      return Locale(languageCode);
    }
    return null; // Return null to use system default
  }

  // --- Auto-Lock Timer ---
  Future<void> saveAutoLockTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockKey, minutes);
  }

  Future<int> loadAutoLockTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 5 minutes
    return prefs.getInt(_autoLockKey) ?? 5;
  }
}