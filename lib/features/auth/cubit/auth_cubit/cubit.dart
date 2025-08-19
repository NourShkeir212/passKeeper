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
    final userId = await SessionManager.getUserId();
    if (userId != null) {
      emit(AuthSuccess());
    } else {
      emit(AuthLoggedOut());
    }
  }


  Future<void> signUp({required String username, required String password,required BuildContext context}) async {
    emit(AuthLoading());
    final hashedPassword = _encryptionService.hashPassword(password);

    // Create the "real" user
    final newUser = User(username: username, password: hashedPassword, profileTag: 'real');
    final result = await _databaseService.insertUser(newUser);

    if (result != -1) {
      // On success, navigate to the mirror setup screen, passing the username
      emit(AuthSuccessSignUp(username));
    } else {
      emit(const AuthFailure('Username already exists.'));
    }
  }

  Future<void> createMirrorAccount({
    required String decoyUsername,
    required String decoyPassword,
    required Map<String, int> customization, // ADD THIS
  }) async {
    emit(AuthLoading());
    try {
      final hashedPassword = _encryptionService.hashPassword(decoyPassword);
      final decoyUser = User(
          username: decoyUsername,
          password: hashedPassword,
          profileTag: 'decoy');
      final userId = await _databaseService.insertUser(decoyUser);

      if (userId == -1) throw Exception("Could not create decoy user.");

      // Pass all the required parameters to the seeding service
      await DataSeedingService().seedDecoyData(
        userId: userId,
        decoyUsername: decoyUsername,
        decoyMasterPassword: decoyPassword,
        customization: customization, // PASS THE MAP
      );

      emit(AuthMirrorSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // --- UPDATED login METHOD ---
  Future<void> login({required String username, required String password,required BuildContext context}) async {
    emit(AuthLoading());
    try {
      final hashedPassword = _encryptionService.hashPassword(password);

      // First, try to log in to the "real" profile
      User? user = await _databaseService.getUserByUsername(username, 'real');
      String profileTag = 'real';

      // If real user doesn't exist or password doesn't match, try the "decoy" profile
      if (user == null || user.password != hashedPassword) {
        user = await _databaseService.getUserByUsername(username, 'decoy');
        profileTag = 'decoy';
      }

      if (user == null || user.password != hashedPassword) {
        throw Exception('Invalid username or password.');
      }

      // Save which profile is active in the session
      await SessionManager.saveActiveProfile(profileTag);

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