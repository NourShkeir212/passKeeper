import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}
// New state for mirror success
class AuthMirrorSuccess extends AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthSuccessSignUp extends AuthState {
  final String username;
  final int userId;

  const AuthSuccessSignUp({required this.username, required this.userId});

  @override
  List<Object> get props => [username, userId];
}
class AuthLoggedOut extends AuthState {}
class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);
  @override
  List<Object> get props => [error];
}