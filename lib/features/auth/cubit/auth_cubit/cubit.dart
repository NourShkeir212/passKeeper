import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

import '../../../../core/services/data_seeding_service.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/encryption_service.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../model/user_model.dart';
import 'states.dart';

class AuthCubit extends Cubit<AuthState> {
  final DatabaseService _databaseService;

  AuthCubit(this._databaseService) : super(AuthInitial());

  final EncryptionService _encryptionService = EncryptionService();

  Future<void> checkSession() async {
    final userId = await SessionManager.getRealUserId();
    if (userId != null) {
      // If a real session exists, set the current vault to the real user
      SessionManager.currentVaultUserId = userId;
      emit(AuthSuccess());
    } else {
      emit(AuthLoggedOut());
    }
  }

  Future<void> unlockWithPassword(String password,context) async {
    emit(AuthLoading());
    try {
      final realUserId = await SessionManager.getRealUserId();
      if (realUserId == null) throw Exception("No active session found.");

      final hashedPassword = _encryptionService.hashPassword(password);

      // 1. Get the real user for this session
      final realUser = await _databaseService.getUserById(realUserId);
      if (realUser == null) throw Exception("Could not find user data.");

      // 2. Check if the password matches the REAL account
      if (realUser.password == hashedPassword) {
        SessionManager.currentSessionProfileTag = 'real';
        SessionManager.currentVaultUserId = realUser.id!; // Set vault to REAL user
        _encryptionService.init(password);
        emit(AuthSuccess());
        return;
      }

      // 3. If not, check if it matches the DECOY account
      final decoyUser = await _databaseService.getDecoyUserFor(realUserId);
      if (decoyUser != null && decoyUser.password == hashedPassword) {
        SessionManager.currentSessionProfileTag = 'decoy';
        // --- THE FIX IS HERE ---
        // Set the vault to the DECOY user's ID for this session
        SessionManager.currentVaultUserId = decoyUser.id!;

        _encryptionService.init(password);
        emit(AuthSuccess());
        return;
      }

      // 4. If it matches neither, the password is wrong
      throw Exception(AppLocalizations.of(context)!.errorIncorrectPassword);
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  Future<void> loginToDecoyWithPassword(String decoyPassword,BuildContext context) async {
    emit(AuthLoading());
    try {
      final realUserId = await SessionManager.getUserId();
      if (realUserId == null) throw Exception("No active session found.");

      final decoyUser = await _databaseService.getDecoyUserFor(realUserId);
      if (decoyUser == null) throw Exception(AppLocalizations.of(context)!.errorIncorrectPassword);

      final hashedDecoyPassword = _encryptionService.hashPassword(decoyPassword);
      if (hashedDecoyPassword != decoyUser.password) {
        throw Exception(AppLocalizations.of(context)!.errorIncorrectPassword);
      }
      SessionManager.currentVaultUserId = decoyUser.id!;
      SessionManager.currentSessionProfileTag = 'decoy';
      _encryptionService.init(decoyPassword);
      emit(AuthSuccess());

    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  Future<void> signUp({required String username, required String password,required BuildContext context}) async {
    emit(AuthLoading());
    final hashedPassword = _encryptionService.hashPassword(password);
    final newUser = User(username: username, password: hashedPassword, profileTag: 'real');
    final result = await _databaseService.insertUser(newUser);

    if (result != -1) {
      emit(AuthSuccessSignUp(username: username,userId: result)); // Pass ID as well
    } else {
      emit( AuthFailure(AppLocalizations.of(context)!.errorUsernameExists));
    }
  }

  Future<void> createMirrorAccount({
    required int realUserId,
    required String decoyUsername,
    required String decoyPassword,
    required Map<String, int> customization,
  }) async
  {
    emit(AuthLoading());
    try {
      final hashedPassword = _encryptionService.hashPassword(decoyPassword);
      final decoyUser = User(
          username: decoyUsername,
          password: hashedPassword,
          profileTag: 'decoy',
          linkedRealUserId: realUserId);
      final userId = await _databaseService.insertUser(decoyUser);
      if (userId == -1) throw Exception("Could not create decoy user.");

      await DataSeedingService().seedDecoyData(
          userId: userId,
          decoyUsername: decoyUsername,
          decoyMasterPassword: decoyPassword,
          customization: customization);

      emit(AuthMirrorSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> login({required String username, required String password,required BuildContext context}) async {
    emit(AuthLoading());
    try {
      final hashedPassword = _encryptionService.hashPassword(password);
      String foundProfileTag = 'real'; // Assume real profile first

      // 1. Try to find a 'real' user with that username
      User? user = await _databaseService.getUserByUsername(username, 'real');

      // 2. If a real user wasn't found, try to find a 'decoy' user
      if (user == null) {
        user = await _databaseService.getUserByUsername(username, 'decoy');
        foundProfileTag = 'decoy';
      }

      SessionManager.currentVaultUserId = user?.id!;

      // 3. Now, verify the password for whichever user was found (if any)
      if (user == null || user.password != hashedPassword) {
        throw Exception(AppLocalizations.of(context)!.errorIncorrectPassword);
      }

      // 4. On success, set the session state and save credentials
      SessionManager.currentSessionProfileTag = foundProfileTag;
      _encryptionService.init(password);
      await SessionManager.saveSession(user.id!);

      emit(AuthSuccess());

    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    // Clear the encryption key from memory
    _encryptionService.clear();
    SessionManager.currentSessionProfileTag = 'real';
    SessionManager.currentVaultUserId = null;
    emit(AuthLoggedOut());
  }


  /// Verifies the master password and initializes the encryption service for the session.
  Future<bool> verifyMasterPassword(String password) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return false;

      // Hash the password the user just entered
      final hashedPassword = _encryptionService.hashPassword(password);

      // Use the existing verifyPassword method with the hashed password
      final isCorrect = await _databaseService.verifyPassword(userId, hashedPassword);

      if (isCorrect) {
        // If correct, initialize the encryption service for the session
        _encryptionService.init(password);
        return true;
      }
      return false;
    } catch(e) {
      return false;
    }
  }
}