import 'package:flutter_bloc/flutter_bloc.dart';

import 'states.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(const ChangePasswordState());

  void toggleCurrentPasswordVisibility() => emit(state.copyWith(isCurrentPasswordVisible: !state.isCurrentPasswordVisible));
  void toggleNewPasswordVisibility() => emit(state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible));
  void toggleConfirmPasswordVisibility() => emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));

  void validatePasswordRealtime(String password) {
    emit(state.copyWith(
      hasMinLength: password.length >= 8,
      hasLetter: RegExp(r'[a-zA-Z]').hasMatch(password),
      hasDigit: RegExp(r'[0-9]').hasMatch(password),
      hasSpecialChar: RegExp(r'[^a-zA-Z0-9]').hasMatch(password),
    ));
  }
}