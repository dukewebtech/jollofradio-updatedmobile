import 'package:local_auth/error_codes.dart' as biometric_error;
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

class Biometrics {
  static bool isEnrolled = true;

  static final LocalAuthentication auth = LocalAuthentication();

  //check biometrics
  static Future<bool> hasBiometrics() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      return canCheckBiometrics;

    } on PlatformException catch(e){
      return false;
    }
  }

  //fetch biometrics
  static Future<List<BiometricType>> getBiometrics() async {
    try {
      final availableBiometrics = 
                           await auth.getAvailableBiometrics();
      return availableBiometrics;

    } on PlatformException catch(e){
      return <BiometricType>[];
    }
  }

  //authenticate BMS
  static Future<bool> authenticate([String? message]) async {
    message = message ?? "Scan Fingerprint to Continue";
    final isEnabled = await hasBiometrics();

    if(!isEnabled) return false; // The device has no biometric

    try{
      return await auth.authenticate(
        localizedReason: message,
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        biometricOnly: true,
        androidAuthStrings: /*ms*/ const AndroidAuthMessages(
          biometricHint: ' '
        ) 
      );
    } on PlatformException catch(e) {
      isEnrolled = !(e.code == biometric_error.notEnrolled) ;
      return false;
    }
  }

  //check biometrics
  static Future<bool> available(String biometricType) async {
    final types = {
      'face': BiometricType.face,
      'fingerprint': BiometricType.fingerprint,
      'iris': BiometricType.iris,
    };

    try {
      final biometrics = await getBiometrics(); // biometrics
      return biometrics.contains(
        types[biometricType]
      );

    } on PlatformException catch(e){
      return false;
    }
  }
}