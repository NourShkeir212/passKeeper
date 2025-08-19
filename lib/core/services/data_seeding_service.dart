import 'dart:math';
import '../../model/account_model.dart';
import '../../model/category_model.dart';
import 'database_services.dart';
import 'encryption_service.dart';

class DataSeedingService {
  final DatabaseService _db = DatabaseService();
  final EncryptionService _encryptionService = EncryptionService();
  final Random _random = Random.secure();

  // --- EXPANDED LIST OF SERVICES ---
  static const List<String> _services = [
    'GitHub', 'Epic Games', 'Proton VPN', 'DeepL', 'Netflix',
    'Stack Overflow', 'Figma', 'Notion', 'ChatGPT', 'Spotify',
    'Discord', 'Twitch', 'Steam', 'Adobe Creative Cloud'
  ];

  /// Generates a believable, human-like password.
  String _generateBelievablePassword(String serviceName) {
    const words = [
      'angel', 'apple', 'blue', 'cheese', 'chocolate', 'computer', 'dragon',
      'dream', 'eagle', 'family', 'football', 'forest', 'freedom', 'galaxy',
      'happy', 'hello', 'hunter', 'jessica', 'love', 'master', 'matrix',
      'michael', 'monkey', 'monster', 'ocean', 'orange', 'password', 'princess',
      'purple', 'qwerty', 'school', 'secret', 'shadow', 'soccer', 'star',
      'summer', 'sunshine', 'tiger', 'winter', 'welcome'
    ];
    const symbols = ['!', '@', '#', '\$', '_', '-'];

    int pattern = _random.nextInt(3);
    String word = words[_random.nextInt(words.length)];
    String symbol = symbols[_random.nextInt(symbols.length)];
    int number = _random.nextInt(999) + 1;

    word = '${word[0].toUpperCase()}${word.substring(1)}';

    switch (pattern) {
      case 0: return '$word$symbol${DateTime.now().year}';
      case 1: return '$word$symbol$number';
      case 2: return '$serviceName$symbol$word';
      default: return '$word$number$symbol';
    }
  }

  /// Generates a realistic random email address based on a name.
  String _generateRandomEmail(String baseName, int index) {
    const domains = ['gmail.com', 'outlook.com', 'yahoo.com'];
    final separators = ['.', '_', ''];

    final separator = separators[_random.nextInt(separators.length)];
    final domain = domains[_random.nextInt(domains.length)];
    final year = 2023 + _random.nextInt(3);

    return '$baseName$separator$year$index@$domain'.toLowerCase();
  }

  Future<void> seedDecoyData({
    required int userId,
    required String decoyUsername,
    required String decoyMasterPassword,
    required Map<String, int> customization,
  }) async {
    const String decoyTag = 'decoy';
    _encryptionService.init(decoyMasterPassword);

    Map<String, int> categoryIds = {};
    final List<Account> accountsToSeed = [];
    final String baseName = decoyUsername.replaceAll(RegExp(r'\d+$'), '');

    final List<String> generatedEmails = [];

    // 1. Generate Email accounts
    if ((customization['gmail'] ?? 0) > 0) {
      categoryIds['Email'] = await _db.insertCategory(Category(userId: userId, name: 'Email', profileTag: decoyTag));
      for (int i = 0; i < customization['gmail']!; i++) {
        final email = _generateRandomEmail(baseName, i);
        generatedEmails.add(email);
        String serviceName = email.contains('gmail') ? 'Gmail' : (email.contains('outlook') ? 'Outlook' : 'Yahoo');
        accountsToSeed.add(Account(
          userId: userId, categoryId: categoryIds['Email']!, serviceName: serviceName,
          username: email,
          password: _encryptionService.encryptText(_generateBelievablePassword(serviceName)),
          profileTag: decoyTag,
        ));
      }
    }

    final String? primaryRecoveryEmail = generatedEmails.isNotEmpty ? generatedEmails.first : null;

    // 2. Generate Social accounts
    if ((customization['facebook'] ?? 0) > 0 || (customization['instagram'] ?? 0) > 0) {
      categoryIds['Social'] = await _db.insertCategory(Category(userId: userId, name: 'Social', profileTag: decoyTag));
    }
    for (int i = 0; i < (customization['facebook'] ?? 0); i++) {
      accountsToSeed.add(Account(
        userId: userId, categoryId: categoryIds['Social']!, serviceName: 'Facebook',
        username: generatedEmails.isNotEmpty ? generatedEmails[i % generatedEmails.length] : _generateRandomEmail(baseName, i),
        password: _encryptionService.encryptText(_generateBelievablePassword('Facebook')),
        recoveryAccount: primaryRecoveryEmail,
        profileTag: decoyTag,
      ));
    }
    for (int i = 0; i < (customization['instagram'] ?? 0); i++) {
      accountsToSeed.add(Account(
        userId: userId, categoryId: categoryIds['Social']!, serviceName: 'Instagram',
        username: generatedEmails.isNotEmpty ? generatedEmails[i % generatedEmails.length] : _generateRandomEmail(baseName, i),
        password: _encryptionService.encryptText(_generateBelievablePassword('Instagram')),
        recoveryAccount: primaryRecoveryEmail,
        profileTag: decoyTag,
      ));
    }

    // 3. Generate Shopping accounts
    if ((customization['shopping'] ?? 0) > 0) {
      categoryIds['Shopping'] = await _db.insertCategory(Category(userId: userId, name: 'Shopping', profileTag: decoyTag));
      for (int i = 0; i < (customization['shopping'] ?? 0); i++) {
        accountsToSeed.add(Account(
          userId: userId, categoryId: categoryIds['Shopping']!, serviceName: 'Amazon',
          username: generatedEmails.isNotEmpty ? generatedEmails[(i + 1) % generatedEmails.length] : _generateRandomEmail(baseName, i),
          password: _encryptionService.encryptText(_generateBelievablePassword('Amazon')),
          profileTag: decoyTag,
        ));
      }
    }

    // 4. Generate Services accounts
    final servicesCount = customization['services'] ?? 0;
    if (servicesCount > 0) {
      categoryIds['Services'] = await _db.insertCategory(Category(userId: userId, name: 'Services', profileTag: decoyTag));
      for (int i = 0; i < servicesCount; i++) {
        final serviceName = _services[_random.nextInt(_services.length)];
        accountsToSeed.add(Account(
          userId: userId, categoryId: categoryIds['Services']!, serviceName: serviceName,
          username: generatedEmails.isNotEmpty ? generatedEmails[i % generatedEmails.length] : _generateRandomEmail(baseName, i),
          password: _encryptionService.encryptText(_generateBelievablePassword(serviceName)),
          recoveryAccount: primaryRecoveryEmail,
          profileTag: decoyTag,
        ));
      }
    }

    // Insert all generated accounts into the database
    for (final account in accountsToSeed) {
      await _db.insertAccount(account);
    }

    _encryptionService.clear();
  }
}






