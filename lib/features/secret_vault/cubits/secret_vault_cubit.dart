import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/database_services.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../model/secret_item_model.dart';
import 'secret_vault_states.dart';
// --- STATES ---

// --- CUBIT ---
class SecretVaultCubit extends Cubit<SecretVaultState> {
  SecretVaultCubit() : super(SecretVaultInitial());

  Future<void> checkVaultStatus() async {
    final pin = await SecureStorageService.getSecretVaultPin();
    emit(SecretVaultLocked(isSetup: pin != null));
  }

  Future<void> setupVault(String pin) async {
    await SecureStorageService.saveSecretVaultPin(pin);
    emit(SecretVaultUnlocked());
  }

  Future<void> unlockVault(String pin) async {
    // 1. Keep the current locked state to revert to on failure.
    final lockedState = state;
    emit(SecretVaultLoading());

    // Use a small delay to make the loading animation visible.
    await Future.delayed(const Duration(milliseconds: 300));

    final storedPin = await SecureStorageService.getSecretVaultPin();
    if (pin == storedPin) {
      emit(SecretVaultUnlocked());
    } else {
      // 2. Emit the error state with a generic, non-translated key.
      emit(const SecretVaultError("errorIncorrectPin"));

      // 3. IMPORTANT: Immediately emit the locked state again.
      if (lockedState is SecretVaultLocked) {
        emit(lockedState);
      }
    }
  }

  Future<void> loadSecretItems() async {
    emit(SecretVaultLoading());
    try {
      final userId = await SessionManager.getRealUserId();
      if (userId == null) throw Exception("User not logged in.");
      final items = await DatabaseService().getSecretItems(userId);
      emit(SecretVaultLoaded(items: items));
    } catch (e) {
      emit(SecretVaultError(e.toString()));
    }
  }

  Future<void> addSecretItem({required String title, required String content}) async {
    final userId = await SessionManager.getRealUserId();
    if (userId == null) return;

    // Encrypt the content before saving
    final encryptedContent = EncryptionService().encryptText(content);

    final newItem = SecretItem(userId: userId, title: title, content: encryptedContent);
    await DatabaseService().addSecretItem(newItem);
    await loadSecretItems();
  }

  Future<void> updateSecretItem(SecretItem item) async {
    // Encrypt the content before saving
    final encryptedContent = EncryptionService().encryptText(item.content);
    await DatabaseService().updateSecretItem(item.copyWith(content: encryptedContent));
    await loadSecretItems();
  }

  Future<void> deleteSecretItem(int id) async {
    await DatabaseService().deleteSecretItem(id);
    await loadSecretItems();
  }

  Future<void> deleteVault() async {
    emit(SecretVaultLoading());
    try {
      final userId = await SessionManager.getRealUserId();
      if (userId == null) throw Exception("User not logged in.");

      // Delete all secret items for the user
      await DatabaseService().deleteAllSecretItemsForUser(userId);

      // Delete the PIN from secure storage
      await SecureStorageService.deleteSecretVaultPin();

      // Go back to the locked state, which will now show the setup screen
      emit(const SecretVaultLocked(isSetup: false));
    } catch (e) {
      emit(SecretVaultError(e.toString()));
    }
  }
}
