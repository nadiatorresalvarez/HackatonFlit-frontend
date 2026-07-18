import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // URL de producción en Render.com
  static const String _prodUrl = 'https://terraguard-arequipa.onrender.com';

  static String get baseUrl {
    // En web siempre usamos producción (GitHub Pages → Render)
    if (kIsWeb) return _prodUrl;
    // En Android emulador
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    // En dispositivo físico o desktop local usar producción
    return _prodUrl;
  }

  static Duration get timeout => const Duration(seconds: 60);
  static Duration get longTimeout => const Duration(seconds: 120);
}
