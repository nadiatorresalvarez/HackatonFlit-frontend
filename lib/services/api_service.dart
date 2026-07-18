import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/terraguard_models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class TerraGuardApiService {
  TerraGuardApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  // ── Health ───────────────────────────────────────────────────────────────
  Future<void> checkHealth() async {
    final r = await _client.get(_uri('/health')).timeout(ApiConfig.timeout);
    if (r.statusCode != 200) {
      throw ApiException('Backend no disponible (${r.statusCode})',
          statusCode: r.statusCode);
    }
  }

  // ── Zonas ────────────────────────────────────────────────────────────────
  Future<List<RiskZone>> fetchZones() async {
    final r = await _client.get(_uri('/api/zones')).timeout(ApiConfig.timeout);
    _ensureOk(r);
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (data['zones'] as List<dynamic>)
        .map((e) => RiskZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Métricas del modelo ──────────────────────────────────────────────────
  Future<ModelMetrics> fetchMetrics() async {
    final r =
        await _client.get(_uri('/api/metrics')).timeout(ApiConfig.timeout);
    _ensureOk(r);
    return ModelMetrics.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  // ── Mapa ─────────────────────────────────────────────────────────────────
  Future<({List<MapFocus> focos, List<MapSamplePoint> puntos})> fetchMapData(
      {int limit = 150}) async {
    final r = await _client
        .get(_uri('/api/map-samples?limit=$limit'))
        .timeout(ApiConfig.timeout);
    _ensureOk(r);
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (
      focos: (data['focos'] as List<dynamic>)
          .map((e) => MapFocus.fromJson(e as Map<String, dynamic>))
          .toList(),
      puntos: (data['puntos'] as List<dynamic>)
          .map((e) => MapSamplePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Visión (análisis de imagen) ──────────────────────────────────────────
  Future<VisionResult> analyzeImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/analyze-image'));
    request.files.add(http.MultipartFile.fromBytes(
      'file', bytes,
      filename: filename,
      contentType: MediaType('image', _imageSubtype(filename)),
    ));
    final streamed = await request.send().timeout(ApiConfig.timeout);
    final r = await http.Response.fromStream(streamed);
    _ensureOk(r);
    return VisionResult.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  // ── Evaluación completa (una sola llamada — v3.0) ────────────────────────
  /// Devuelve predicción + indicadores + salud + económico + reporte Markdown.
  /// [zona] es opcional si se proporcionan [lat] y [lon].
  Future<FullAssessmentResult> fullAssessment({
    required double ph,
    required double clorosisPct,
    required double necrosisPct,
    String? zona,
    double? lat,
    double? lon,
  }) async {
    final body = <String, dynamic>{
      'ph': ph,
      'clorosis_pct': clorosisPct,
      'necrosis_pct': necrosisPct,
      if (zona != null) 'zona': zona,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
    final r = await _client
        .post(
          _uri('/api/full-assessment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.longTimeout);
    _ensureOk(r);
    return FullAssessmentResult.fromJson(
        jsonDecode(r.body) as Map<String, dynamic>);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  void _ensureOk(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    String msg = 'Error del servidor (${r.statusCode})';
    try {
      final data = jsonDecode(r.body);
      if (data is Map && data['detail'] != null) {
        msg = data['detail'].toString();
      }
    } catch (_) {}
    throw ApiException(msg, statusCode: r.statusCode);
  }

  String _imageSubtype(String filename) {
    final l = filename.toLowerCase();
    if (l.endsWith('.png')) return 'png';
    if (l.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }
}
