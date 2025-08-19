import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'userId';

  // This variable holds the profile tag for the CURRENT SESSION ONLY.
  // It resets to 'real' every time the app starts.
  static String currentSessionProfileTag = 'real';

  // This is the permanently saved REAL user ID for the session
  static Future<int?> getRealUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }
  static int? currentVaultUserId;

  static Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
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