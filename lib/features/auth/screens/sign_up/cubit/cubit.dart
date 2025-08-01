// --- CUBIT ---
import 'package:flutter_bloc/flutter_bloc.dart';
import 'states.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(const SignUpState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }


  void validatePasswordRealtime(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    // --- UPDATED LINE ---
    final hasSpecialChar = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);

    // إصدار حالة جديدة مع قيم التحقق المحدثة
    emit(state.copyWith(
      hasMinLength: hasMinLength,
      hasLetter: hasLetter,
      hasDigit: hasDigit,
      hasSpecialChar: hasSpecialChar,
    ));
  }
}