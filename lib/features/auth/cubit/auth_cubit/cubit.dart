import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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


  Future<void> signUp(
      {required String username, required String password}) async {
    emit(AuthLoading());

    // 1. HASH the master password for storage (one-way).
    final hashedPassword = _encryptionService.hashPassword(password);

    final newUser = User(username: username, password: hashedPassword);
    final result = await _databaseService.insertUser(newUser);

    if (result != -1) {
      emit(AuthSuccessSignUp());
    } else {
      emit(const AuthFailure('Username already exists. Please choose another.'));
    }
  }

  Future<void> login(
      {required String username, required String password}) async {
    emit(AuthLoading());
    try {
      // 1. Fetch user by username only.
      final user = await _databaseService.getUserByUsername(username);
      if (user == null) {
        throw Exception('Invalid username or password.');
      }

      // 2. Hash the entered password and compare it with the stored hash.
      final hashedPassword = _encryptionService.hashPassword(password);
      if (hashedPassword != user.password) {
        throw Exception('Invalid username or password.');
      }

      // 3. If hashes match, login is successful. Initialize the encryption service.
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