import 'package:flutter_bloc/flutter_bloc.dart';
import 'account_form_state.dart';


class AccountFormCubit extends Cubit<AccountFormState> {
  AccountFormCubit() : super(const AccountFormState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void selectCategory(int? categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  void selectService(String? service) {
    emit(state.copyWith(selectedService: service));
  }

  void updatePasswordStrength(String password) {
    double score = 0;
    if (password.isEmpty) {
      emit(state.copyWith(passwordStrength: 0.0));
      return;
    }
    if (password.length >= 8) score += 0.25;
    if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) score += 0.25;

    emit(state.copyWith(passwordStrength: score));
  }
}