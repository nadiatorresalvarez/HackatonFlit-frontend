import 'package:flutter/foundation.dart';

/// Configuración de conexión con el backend TerraGuard.
class ApiConfig {
  ApiConfig._();

  /// URL base del adaptador REST (`api_server.py`).
  ///
  /// - Android emulador: `http://10.0.2.2:8000`
  /// - iOS simulador / desktop / web: `http://localhost:8000`
  /// - Dispositivo físico: IP de tu PC en la red local.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://localhost:8000';
    }
  }

  static Duration get timeout => const Duration(seconds: 60);
}
