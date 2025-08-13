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

class SettingsExporting extends SettingsState {}
class SettingsExportSuccess extends SettingsState {}
class SettingsExportFailure extends SettingsState {
  final String error;
  const SettingsExportFailure(this.error);
}

class SettingsImporting extends SettingsState {}
class SettingsImportSuccess extends SettingsState {
  final String message;
  const SettingsImportSuccess(this.message);
}
class SettingsImportFailure extends SettingsState {
  final String error;
  const SettingsImportFailure(this.error);
}
class DeleteUserSuccess extends SettingsState {}
class DeleteUserFailure extends SettingsState {
  final String error;
  const DeleteUserFailure(this.error);
}
