import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'userId';

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