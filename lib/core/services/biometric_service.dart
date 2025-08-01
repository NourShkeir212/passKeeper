import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Authenticates the user with biometrics.
  /// Returns true if successful, false otherwise.
  static Future<bool> authenticate() async {
    try {
      // Check if biometrics are available on the device
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        print("Biometrics not available");
        return false;
      }

      // Authenticate
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your vault',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the dialog open on app switch
          biometricOnly: true, // Only allow biometrics, not device PIN
        ),
      );
    } on PlatformException catch (e) {
      print("Error during biometric authentication: $e");
      return false;
    }
  }
}