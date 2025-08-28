import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../model/secret_item_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _masterPasswordKey = 'masterPassword';
  static const _secretVaultPinKey = 'secretVaultPin';

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
  static Future<void> saveSecretVaultPin(String pin) async {
    await _storage.write(key: _secretVaultPinKey, value: pin);
  }

  static Future<String?> getSecretVaultPin() async {
    return await _storage.read(key: _secretVaultPinKey);
  }

  /// Deletes the secret vault PIN.
  static Future<void> deleteSecretVaultPin() async {
    await _storage.delete(key: _secretVaultPinKey);
  }
}