import 'package:equatable/equatable.dart';

class AccountFormState extends Equatable {
  final int? selectedCategoryId;
  final String? selectedService;
  final bool isPasswordVisible;
  final double passwordStrength;

  const AccountFormState({
    this.selectedCategoryId,
    this.selectedService,
    this.isPasswordVisible = false,
    this.passwordStrength = 0.0,
  });

  AccountFormState copyWith({
    int? selectedCategoryId,
    String? selectedService,
    bool? isPasswordVisible,
    double? passwordStrength,
  }) {
    return AccountFormState(
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedService: selectedService ?? this.selectedService,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }

  @override
  List<Object?> get props => [selectedCategoryId, selectedService, isPasswordVisible, passwordStrength];
}