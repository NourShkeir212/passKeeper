import 'package:equatable/equatable.dart';

import '../../../model/user_model.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  final bool isBiometricEnabled;
  final int autoLockMinutes;
  final User? realUser;
  final User? decoyUser;
  final bool canCheckBiometrics;
  final bool hasBiometricsEnrolled;
  final int passwordReminderFrequency;

  const SettingsInitial({
    required this.isBiometricEnabled,
    required this.autoLockMinutes,
    this.realUser,
    this.decoyUser,
    required this.canCheckBiometrics,
    required this.hasBiometricsEnrolled,
    required this.passwordReminderFrequency,
  });

  @override
  List<Object?> get props => [
    isBiometricEnabled,
    autoLockMinutes,
    realUser,
    decoyUser,
    canCheckBiometrics,
    hasBiometricsEnrolled,
    passwordReminderFrequency
  ];
}

class SettingsLoading extends SettingsState {}

// States for Password Change
class ChangePasswordSuccess extends SettingsState {}
class ChangePasswordFailure extends SettingsState {
  final String error;
  const ChangePasswordFailure(this.error);
  @override
  List<Object> get props => [error];
}

// States for Data Export
class SettingsExporting extends SettingsState {}
class SettingsExportSuccess extends SettingsState {}
class SettingsExportFailure extends SettingsState {
  final String error;
  const SettingsExportFailure(this.error);
  @override
  List<Object> get props => [error];
}

// States for Data Import
class SettingsImporting extends SettingsState {}
class SettingsImportSuccess extends SettingsState {
  final String message;
  const SettingsImportSuccess(this.message);
  @override
  List<Object> get props => [message];
}
class SettingsImportFailure extends SettingsState {
  final String error;
  const SettingsImportFailure(this.error);
  @override
  List<Object> get props => [error];
}

// States for User Deletion
class DeleteUserSuccess extends SettingsState {}
class DeleteUserFailure extends SettingsState {
  final String error;
  const DeleteUserFailure(this.error);
  @override
  List<Object> get props => [error];
}