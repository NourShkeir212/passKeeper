import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/database_services.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/services/settings_service.dart';
import 'states.dart';

// --- STATES ---


// --- CUBIT ---
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
}