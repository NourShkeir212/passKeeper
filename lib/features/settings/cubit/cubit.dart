import 'package:encrypt/encrypt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      : super(const SettingsInitial(isBiometricEnabled: true));

  Future<void> loadSettings() async {
    final isBiometricEnabled = await _settingsService.loadBiometricPreference();
    emit(SettingsInitial(isBiometricEnabled: isBiometricEnabled));
  }

  Future<void> toggleBiometrics(bool isEnabled) async {
    await _settingsService.saveBiometricPreference(isEnabled);
    emit(SettingsInitial(isBiometricEnabled: isEnabled));
  }

  Future<void> changeMasterPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Keep the last known value of biometrics to restore it later
    final currentBiometricSetting = (state is SettingsInitial) ? (state as SettingsInitial).isBiometricEnabled : true;

    emit(SettingsLoading());
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User not found");

      // 1. Verify the user's OLD password.
      final encryptionService = EncryptionService();
      final hashedOldPassword = encryptionService.hashPassword(oldPassword);
      final isVerified = await _databaseService.verifyPassword(userId, hashedOldPassword);

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
        // Decrypt the stored password using the old key
        final decryptedPassword = oldEncrypter.decrypt64(account.password.split(':')[1], iv: IV.fromBase64(account.password.split(':')[0]));

        // Re-encrypt the password with the new key
        final iv = IV.fromSecureRandom(16);
        final reEncryptedPassword = newEncrypter.encrypt(decryptedPassword, iv: iv);
        final combined = '${iv.base64}:${reEncryptedPassword.base64}';

        reEncryptedAccounts.add(account.copyWith(password: combined));
      }

      // 5. Save all the re-encrypted accounts back to the database in a batch.
      if (reEncryptedAccounts.isNotEmpty) {
        await _databaseService.updateAccountsBatch(reEncryptedAccounts);
      }

      // 6. Finally, save the new HASHED master password.
      final hashedNewPassword = encryptionService.hashPassword(newPassword);
      await _databaseService.updatePassword(userId, hashedNewPassword);

      // 7. Re-initialize the encryption service with the new password for the current session.
      encryptionService.init(newPassword);

      emit(ChangePasswordSuccess());

    } catch (e) {
      emit(ChangePasswordFailure(e.toString().replaceFirst("Exception: ", "")));
    } finally {
      // Revert to a stable state so the previous screen doesn't show a spinner.
      emit(SettingsInitial(isBiometricEnabled: currentBiometricSetting));
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
}