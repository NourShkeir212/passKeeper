import 'package:equatable/equatable.dart';

// --- STATE ---
class ChangePasswordState extends Equatable {
  final bool isCurrentPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool hasMinLength;
  final bool hasLetter;
  final bool hasDigit;
  final bool hasSpecialChar;

  const ChangePasswordState({
    this.isCurrentPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.hasMinLength = false,
    this.hasLetter = false,
    this.hasDigit = false,
    this.hasSpecialChar = false,
  });

  ChangePasswordState copyWith({
    bool? isCurrentPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? hasMinLength,
    bool? hasLetter,
    bool? hasDigit,
    bool? hasSpecialChar,
  }) {
    return ChangePasswordState(
      isCurrentPasswordVisible: isCurrentPasswordVisible ?? this.isCurrentPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasLetter: hasLetter ?? this.hasLetter,
      hasDigit: hasDigit ?? this.hasDigit,
      hasSpecialChar: hasSpecialChar ?? this.hasSpecialChar,
    );
  }

  @override
  List<Object> get props => [
    isCurrentPasswordVisible,
    isNewPasswordVisible,
    isConfirmPasswordVisible,
    hasMinLength,
    hasLetter,
    hasDigit,
    hasSpecialChar
  ];
}
