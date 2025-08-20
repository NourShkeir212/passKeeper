import 'package:equatable/equatable.dart';

// --- STATE ---
class SignUpState extends Equatable {
  final bool isPasswordVisible;
  final bool hasMinLength;
  final bool hasLetter;
  final bool hasDigit;
  final bool hasSpecialChar;

  const SignUpState({
    this.isPasswordVisible = false,
    this.hasMinLength = false,
    this.hasLetter = false,
    this.hasDigit = false,
    this.hasSpecialChar = false,
  });

  SignUpState copyWith({
    bool? isPasswordVisible,
    bool? hasMinLength,
    bool? hasLetter,
    bool? hasDigit,
    bool? hasSpecialChar,
  }) {
    return SignUpState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasLetter: hasLetter ?? this.hasLetter,
      hasDigit: hasDigit ?? this.hasDigit,
      hasSpecialChar: hasSpecialChar ?? this.hasSpecialChar,
    );
  }

  @override
  List<Object> get props => [isPasswordVisible, hasMinLength, hasLetter, hasDigit, hasSpecialChar];
}
