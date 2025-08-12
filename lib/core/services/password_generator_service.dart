import 'dart:math';

class PasswordGeneratorService {
  static String generatePassword({
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    int length = 16,
  }) {
    const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numberChars = '0123456789';
    const String symbolChars = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String chars = lowercaseChars;
    if (includeUppercase) chars += uppercaseChars;
    if (includeNumbers) chars += numberChars;
    if (includeSymbols) chars += symbolChars;

    final Random random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }
}