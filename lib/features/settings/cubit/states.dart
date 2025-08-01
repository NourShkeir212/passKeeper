import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object> get props => [];
}
class SettingsInitial extends SettingsState {
  final bool isBiometricEnabled;
  const SettingsInitial({required this.isBiometricEnabled});
  @override
  List<Object> get props => [isBiometricEnabled];
}
class SettingsLoading extends SettingsState {}
class ChangePasswordSuccess extends SettingsState {}
class ChangePasswordFailure extends SettingsState {
  final String error;
  const ChangePasswordFailure(this.error);
}