import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../model/user_model.dart';
import 'states.dart';

class AuthCubit extends Cubit<AuthState> {
  final DatabaseService _databaseService;

  AuthCubit(this._databaseService) : super(AuthInitial());

  Future<void> signUp({required String username, required String password}) async {
    emit(AuthLoading());



    final newUser = User(username: username, password: password);
    final result = await _databaseService.insertUser(newUser);

    if (result != -1) {
      emit(AuthSuccess());
    } else {
      emit(const AuthFailure('Username already exists. Please choose another.'));
    }
  }
  /// Checks if a session is already active when the app starts.
  Future<void> checkSession() async {
    final userId = await SessionManager.getUserId();
    if (userId != null) {
      emit(AuthSuccess());
    } else {
      emit(AuthLoggedOut());
    }
  }

  /// Handles user login and saves the session.
  @override
  Future<void> login({required String username, required String password}) async {
    emit(AuthLoading());
    final user = await _databaseService.getUser(username, password);

    if (user != null) {
      await SessionManager.saveSession(user.id!); // Save session
      emit(AuthSuccess());
    } else {
      emit(const AuthFailure('Invalid username or password.'));
    }
  }

  /// Handles user logout and clears the session.
  Future<void> logout() async {
    await SessionManager.clearSession();
    emit(AuthLoggedOut());
  }
}