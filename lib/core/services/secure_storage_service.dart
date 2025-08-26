import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _masterPasswordKey = 'masterPassword';

  /// Saves the user's master password to the device's secure storage.
  static Future<void> saveMasterPassword(String password) async {
    await _storage.write(key: _masterPasswordKey, value: password);
  }

  /// Retrieves the master password from secure storage.
  static Future<String?> getMasterPassword() async {
    return await _storage.read(key: _masterPasswordKey);
  }

  /// Deletes the master password on logout or account deletion.
  static Future<void> deleteMasterPassword() async {
    await _storage.delete(key: _masterPasswordKey);
  }
}