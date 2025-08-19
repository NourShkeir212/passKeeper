import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'userId';
  static const _keyProfileTag = 'profileTag'; // NEW KEY

  static Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  static Future<void> saveActiveProfile(String profileTag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileTag, profileTag);
  }

  static Future<String> getActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to "real" if not set
    return prefs.getString(_keyProfileTag) ?? 'real';
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}