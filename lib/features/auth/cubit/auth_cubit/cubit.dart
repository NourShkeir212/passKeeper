import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/database_services.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../model/user_model.dart';
import 'states.dart';

class AuthCubit extends Cubit<AuthState> {
  final DatabaseService _databaseService;

  AuthCubit(this._databaseService) : super(AuthInitial());

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
    final newUser = User(username: username, password: password);
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
    final user = await _databaseService.getUser(username, password);

    if (user != null) {
      await SessionManager.saveSession(user.id!);
      emit(AuthSuccess());
    } else {
      emit(const AuthFailure('Invalid username or password.'));
    }
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    emit(AuthLoggedOut());
  }
}