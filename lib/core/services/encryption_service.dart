import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Singleton pattern
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  encrypt.Encrypter? _encrypter;
  bool get isInitialized => _encrypter != null;
  /// Initializes the encrypter with a key derived from the user's master password.
  void init(String masterPassword) {
    final key = _deriveKey(masterPassword);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  /// Derives a secure 32-byte key from the user's password using SHA-256.
  encrypt.Key _deriveKey(String password) {
    var passwordBytes = utf8.encode(password);
    var hash = sha256.convert(passwordBytes);

    // FIX: Convert the List<int> from hash.bytes into a Uint8List
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  /// Encrypts a piece of plain text.
  String encryptText(String plainText) {
    if (_encrypter == null) throw Exception("EncryptionService not initialized.");
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter!.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a combined "iv:encrypted" string.
  String decryptText(String combined) {
    if (_encrypter == null) throw Exception("EncryptionService not initialized.");
    try {
      final parts = combined.split(':');
      if (parts.length != 2) return "Invalid Data";
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
      print("Decryption Error: $e");
      return "Decryption Error";
    }
  }

  /// Hashes a password using SHA-256. This is a one-way process.
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString(); // Returns the hex string representation of the hash
  }
  /// Clears the encryption key from memory on logout.
  void clear() {
    _encrypter = null;
  }
}