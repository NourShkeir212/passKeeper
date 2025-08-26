import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/database_services.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/excel_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/services/settings_service.dart';
import '../../../model/account_model.dart';
import '../../home/cubit/account_cubit/cubit.dart';
import '../../home/cubit/category_cubit/cubit.dart';
import 'states.dart';


class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;
  final DatabaseService _databaseService;

  SettingsCubit(this._settingsService, this._databaseService)
      : super(const SettingsInitial(
      isBiometricEnabled: true,
      autoLockMinutes: 5,
      passwordReminderFrequency: 5,
      canCheckBiometrics: false,
      hasBiometricsEnrolled: false));

  Future<void> loadSettings() async {
    try {
     final passwordReminderFrequency = await _settingsService.loadPasswordReminderFrequency();
      final results = await Future.wait([
        _settingsService.loadBiometricPreference(),
        _settingsService.loadAutoLockTime(),
        SessionManager.getRealUserId(),
        BiometricService.canCheckBiometrics(),
        BiometricService.hasEnrolledBiometrics(),

      ]);

      final isBiometricEnabled = results[0] as bool;
      final autoLockMinutes = results[1] as int;
      final realUserId = results[2] as int?;
      final canCheckBiometrics = results[3] as bool;
      final hasBiometricsEnrolled = results[4] as bool;

      if (realUserId == null) throw Exception("Active user session not found.");

      final realUser = await _databaseService.getUserById(realUserId);
      if (realUser == null) throw Exception("Could not load user data from database.");

      final decoyUser = await _databaseService.getDecoyUserFor(realUserId);

      emit(SettingsInitial(
        isBiometricEnabled: isBiometricEnabled,
        autoLockMinutes: autoLockMinutes,
        realUser: realUser,
        decoyUser: decoyUser,
        canCheckBiometrics: canCheckBiometrics,
        passwordReminderFrequency: passwordReminderFrequency,
        hasBiometricsEnrolled: hasBiometricsEnrolled,
      ));
    } catch (e) {
      print("Failed to load settings: $e");
      // emit(SettingsLoadFailure(e.toString()));
    }
  }

  Future<void> changePasswordReminderFrequency(int count) async {
    await _settingsService.savePasswordReminderFrequency(count);
    await _settingsService.resetBiometricUnlockCount(); // Reset counter when frequency changes
    loadSettings();
  }

  Future<void> toggleBiometrics(bool isEnabled) async {
    await _settingsService.saveBiometricPreference(isEnabled);
    loadSettings();
  }

  Future<void> changeAutoLockTime(int minutes) async {
    await _settingsService.saveAutoLockTime(minutes);
    loadSettings();
  }


  Future<void> changeMasterPassword({
    required String oldPassword,
    required String newPassword,
    required BuildContext context
  }) async {
    // Keep the current state to restore it after the operation
    final currentState = state;
    emit(SettingsLoading());
    try {
      final userId = await SessionManager.getRealUserId();
      if (userId == null) throw Exception("User not found");

      // 1. Verify the user's OLD password.
      final encryptionService = EncryptionService();
      final hashedOldPassword = encryptionService.hashPassword(oldPassword);
      final isVerified = await _databaseService.verifyPassword(
          userId, hashedOldPassword);

      if (!isVerified) {
        throw Exception(AppLocalizations.of(context)!.errorIncorrectPassword);
      }

      // 2. NEW: Check against the decoy password
      final decoyUser = await _databaseService.getDecoyUserFor(userId);
      if (decoyUser != null) {
        final hashedNewPassword = encryptionService.hashPassword(newPassword);
        if (hashedNewPassword == decoyUser.password) {
          throw Exception(
              AppLocalizations.of(context)!.errorPasswordMatchesDecoy);
        }
      }

      // 3. Fetch ALL accounts.
      final allAccounts = await _databaseService.getAllAccountsForUser(
          userId, 'real');

      // 4. Create encrypters for both old and new passwords.
      final oldEncrypter = encryptionService.createEncrypter(oldPassword);
      final newEncrypter = encryptionService.createEncrypter(newPassword);

      // 5. Decrypt with the old key and re-encrypt with the new key.
      final List<Account> reEncryptedAccounts = [];
      for (final account in allAccounts) {
        final parts = account.password.split(':');
        final iv = IV.fromBase64(parts[0]);
        final encrypted = Encrypted.fromBase64(parts[1]);
        final decryptedPassword = oldEncrypter.decrypt(encrypted, iv: iv);

        final newIv = IV.fromSecureRandom(16);
        final reEncryptedPassword = newEncrypter.encrypt(
            decryptedPassword, iv: newIv);
        final combined = '${newIv.base64}:${reEncryptedPassword.base64}';

        reEncryptedAccounts.add(account.copyWith(password: combined));
      }

      // 6. Save all the re-encrypted accounts back to the database in a batch.
      if (reEncryptedAccounts.isNotEmpty) {
        await _databaseService.updateAccountsBatch(reEncryptedAccounts);
      }

      // 7. Save the new HASHED master password to the database.
      final hashedNewPassword = encryptionService.hashPassword(newPassword);
      await _databaseService.updatePassword(userId, hashedNewPassword);

      // 8. Re-initialize the encryption service with the new password for the current session.
      encryptionService.init(newPassword);
      await SecureStorageService.saveMasterPassword(newPassword);
      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFailure(e.toString().replaceFirst("Exception: ", "")));
    } finally {
      // Revert to a stable state so the previous screen doesn't show a spinner.
      if (currentState is SettingsInitial) {
        emit(currentState);
      } else {
        loadSettings();
      }
    }
  }

  final ExcelService _exportService = ExcelService();

  Future<void> exportData() async {
    emit(SettingsExporting());
    try {
      await _exportService.exportAccountsToExcel();
      emit(SettingsExportSuccess());
      // Revert to initial state after success
      loadSettings();
    } catch (e) {
      emit(SettingsExportFailure(e.toString()));
    }
  }

  Future<void> importData({
    required AccountCubit accountCubit,
    required CategoryCubit categoryCubit,
    required BuildContext context,
  }) async {
    emit(SettingsImporting());
    try {
      final message = await _exportService.importAccountsFromExcel();

      accountCubit.loadAccounts();
      categoryCubit.loadCategories();

      emit(SettingsImportSuccess(message));
      loadSettings();
    } catch (e) {
      emit(SettingsImportFailure(e.toString()));
    }
  }

  Future<void> deleteUserAccount(String password,context) async {
    // Keep the current state to revert to on failure
    final currentState = state;
    emit(SettingsLoading());
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User session not found.");

      // 1. Verify the password
      final encryptionService = EncryptionService();
      final hashedPassword = encryptionService.hashPassword(password);
      final isVerified = await _databaseService.verifyPassword(userId, hashedPassword);

      if (!isVerified) {
        throw Exception(AppLocalizations.of(context)!.errorIncorrectPassword);
      }

      // 2. If verified, delete the user from the database
      await _databaseService.deleteUser(userId);
      await SecureStorageService.deleteMasterPassword();
      emit(DeleteUserSuccess());

    } catch (e) {
      emit(DeleteUserFailure(e.toString().replaceFirst("Exception: ", "")));
      // Revert to the previous state on failure
      emit(currentState);
    }
  }

  /// Deletes the current decoy user and all their data.
  Future<void> resetDecoyVault() async {
    try {
      // Get the real user's ID to find the linked decoy account
      final realUserId = await SessionManager.getUserId();
      if (realUserId == null) return;

      // Find the decoy user that is linked to the real user
      final decoyUser = await _databaseService.getDecoyUserFor(realUserId);

      if (decoyUser != null) {
        // Delete the decoy user (ON DELETE CASCADE will handle their data)
        await _databaseService.deleteUser(decoyUser.id!);
      }

      // After deletion, reload the settings to update the UI
      await loadSettings();
    } catch (e) {
      emit(DeleteUserFailure(e.toString()));
    }
  }
}