import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/database_services.dart';
import '../../../core/services/excel_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/services/settings_service.dart';
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

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(SettingsLoading());
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User not found");

      final isVerified = await _databaseService.verifyPassword(
          userId, oldPassword);
      if (!isVerified) {
        throw Exception("Incorrect current password.");
      }

      await _databaseService.updatePassword(userId, newPassword);
      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFailure(e.toString().replaceFirst("Exception: ", "")));
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