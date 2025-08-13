import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../../core/services/database_services.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/excel_service.dart';
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
      : super(const SettingsInitial(isBiometricEnabled: true, autoLockMinutes: 5));

  Future<void> loadSettings() async {
    final isBiometricEnabled = await _settingsService.loadBiometricPreference();
    final autoLockMinutes = await _settingsService.loadAutoLockTime();
    emit(SettingsInitial(isBiometricEnabled: isBiometricEnabled,autoLockMinutes: autoLockMinutes));
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
  }) async {
    // Keep the last known value of settings to restore it later
    final currentState = state;
    emit(SettingsLoading());
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User not found");

      // 1. Verify the user's OLD password.
      final encryptionService = EncryptionService();
      final hashedOldPassword = encryptionService.hashPassword(oldPassword);
      final isVerified = await _databaseService.verifyPassword(
          userId, hashedOldPassword);

      if (!isVerified) {
        throw Exception("Incorrect current password.");
      }

      // 2. Fetch ALL accounts.
      final allAccounts = await _databaseService.getAllAccountsForUser(userId);

      // 3. Create encrypters for both old and new passwords.
      final oldEncrypter = encryptionService.createEncrypter(oldPassword);
      final newEncrypter = encryptionService.createEncrypter(newPassword);

      // 4. Decrypt with the old key and re-encrypt with the new key.
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

      // 5. Save all the re-encrypted accounts back to the database in a batch.
      if (reEncryptedAccounts.isNotEmpty) {
        await _databaseService.updateAccountsBatch(reEncryptedAccounts);
      }

      // 6. Save the new HASHED master password to the database.
      final hashedNewPassword = encryptionService.hashPassword(newPassword);
      await _databaseService.updatePassword(userId, hashedNewPassword);

      // 8. Re-initialize the encryption service with the new password for the current session.
      encryptionService.init(newPassword);

      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFailure(e.toString().replaceFirst("Exception: ", "")));
    } finally {
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
      final message = await _exportService.importAccountsFromExcel(context);

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
      emit(DeleteUserSuccess());

    } catch (e) {
      emit(DeleteUserFailure(e.toString().replaceFirst("Exception: ", "")));
      // Revert to the previous state on failure
      emit(currentState);
    }
  }
}