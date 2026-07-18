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

  Future<void> checkHealth() async {
    final response = await _client
        .get(_uri('/health'))
        .timeout(ApiConfig.timeout);
    if (response.statusCode != 200) {
      throw ApiException(
        'Backend no disponible (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<RiskZone>> fetchZones() async {
    final response = await _client
        .get(_uri('/api/zones'))
        .timeout(ApiConfig.timeout);
    _ensureOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['zones'] as List<dynamic>;
    return list
        .map((e) => RiskZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ModelMetrics> fetchMetrics() async {
    final response = await _client
        .get(_uri('/api/metrics'))
        .timeout(ApiConfig.timeout);
    _ensureOk(response);
    return ModelMetrics.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<({List<MapFocus> focos, List<MapSamplePoint> puntos})> fetchMapData({
    int limit = 150,
  }) async {
    final response = await _client
        .get(_uri('/api/map-samples?limit=$limit'))
        .timeout(ApiConfig.timeout);
    _ensureOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final focos = (data['focos'] as List<dynamic>)
        .map((e) => MapFocus.fromJson(e as Map<String, dynamic>))
        .toList();
    final puntos = (data['puntos'] as List<dynamic>)
        .map((e) => MapSamplePoint.fromJson(e as Map<String, dynamic>))
        .toList();
    return (focos: focos, puntos: puntos);
  }

  Future<VisionResult> analyzeImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/analyze-image'),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType('image', _imageSubtype(filename)),
      ),
    );
    final streamed = await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamed);
    _ensureOk(response);
    return VisionResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<PredictionResult> predict({
    required String zona,
    required double ph,
    required double clorosisPct,
    required double necrosisPct,
    double? lat,
    double? lon,
    String? visionMsg,
  }) async {
    final body = <String, dynamic>{
      'zona': zona,
      'ph': ph,
      'clorosis_pct': clorosisPct,
      'necrosis_pct': necrosisPct,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
    final response = await _client
        .post(
          _uri('/api/predict'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    _ensureOk(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (visionMsg != null) {
      json['vision_msg'] = visionMsg;
    }
    return PredictionResult.fromJson(json);
  }

  Future<String> generateReport({
    required PredictionResult prediction,
    String? apiKey,
  }) async {
    final body = {
      'zona': prediction.zona,
      'metal': prediction.metal,
      'riesgo': prediction.riesgoTxt,
      'dist': prediction.distKm,
      'ph': prediction.ph,
      'clorosis': prediction.clorosisPct,
      'necrosis': prediction.necrosisPct,
      if (apiKey != null && apiKey.isNotEmpty) 'api_key': apiKey,
    };
    final response = await _client
        .post(
          _uri('/api/report'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    _ensureOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reporte'] as String;
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'Error del servidor (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['detail'] != null) {
        message = data['detail'].toString();
      }
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }

  String _imageSubtype(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }
}
