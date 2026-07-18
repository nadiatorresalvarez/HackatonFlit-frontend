import 'package:flutter/foundation.dart';

import '../models/terraguard_models.dart';
import '../services/api_service.dart';

enum AnalysisStep { idle, analyzingImage, predicting, done, error }

class AnalysisProvider extends ChangeNotifier {
  AnalysisProvider({TerraGuardApiService? api})
      : _api = api ?? TerraGuardApiService();

  final TerraGuardApiService _api;

  List<RiskZone> zones = [];
  ModelMetrics? metrics;
  List<MapFocus> mapFocos = [];
  List<MapSamplePoint> mapPuntos = [];

  bool loadingZones = false;
  bool loadingMetrics = false;
  bool loadingMap = false;
  bool processing = false;
  bool generatingReport = false;

  AnalysisStep step = AnalysisStep.idle;
  String? errorMessage;
  String? reportMarkdown;

  PredictionResult? lastPrediction;
  Uint8List? imagePreviewBytes;
  String? imageFilename;

  Future<void> bootstrap() async {
    await Future.wait([
      loadZones(),
      loadMetrics(),
      loadMapData(),
    ]);
  }

  Future<void> loadZones() async {
    loadingZones = true;
    notifyListeners();
    try {
      zones = await _api.fetchZones();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loadingZones = false;
      notifyListeners();
    }
  }

  Future<void> loadMetrics() async {
    loadingMetrics = true;
    notifyListeners();
    try {
      metrics = await _api.fetchMetrics();
    } catch (_) {
      // Métricas opcionales para la pantalla de info.
    } finally {
      loadingMetrics = false;
      notifyListeners();
    }
  }

  Future<void> loadMapData() async {
    loadingMap = true;
    notifyListeners();
    try {
      final data = await _api.fetchMapData();
      mapFocos = data.focos;
      mapPuntos = data.puntos;
    } catch (_) {
      // El mapa puede mostrar solo focos estáticos si falla.
    } finally {
      loadingMap = false;
      notifyListeners();
    }
  }

  Future<PredictionResult?> runAnalysis({
    required String zona,
    required double ph,
    required double clorosisManual,
    required double necrosisManual,
    required bool useManualSymptoms,
    double? lat,
    double? lon,
  }) async {
    processing = true;
    step = AnalysisStep.analyzingImage;
    errorMessage = null;
    reportMarkdown = null;
    notifyListeners();

    try {
      double clorosis = clorosisManual;
      double necrosis = necrosisManual;
      String? visionMsg;

      if (!useManualSymptoms && imagePreviewBytes != null) {
        final vision = await _api.analyzeImage(
          bytes: imagePreviewBytes!,
          filename: imageFilename ?? 'hoja.jpg',
        );
        clorosis = vision.clorosisPct;
        necrosis = vision.necrosisPct;
        visionMsg = vision.msg;
        if (!vision.ok) {
          visionMsg = '${vision.msg} (valores estimados)';
        }
      }

      step = AnalysisStep.predicting;
      notifyListeners();

      final prediction = await _api.predict(
        zona: zona,
        ph: ph,
        clorosisPct: clorosis,
        necrosisPct: necrosis,
        lat: lat,
        lon: lon,
        visionMsg: visionMsg,
      );

      lastPrediction = prediction;
      step = AnalysisStep.done;
      return prediction;
    } catch (e) {
      step = AnalysisStep.error;
      errorMessage = e.toString();
      return null;
    } finally {
      processing = false;
      notifyListeners();
    }
  }

  Future<String?> createReport({
    PredictionResult? prediction,
    String? apiKey,
  }) async {
    final target = prediction ?? lastPrediction;
    if (target == null) return null;

    generatingReport = true;
    errorMessage = null;
    notifyListeners();

    try {
      reportMarkdown = await _api.generateReport(
        prediction: target,
        apiKey: apiKey,
      );
      return reportMarkdown;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      generatingReport = false;
      notifyListeners();
    }
  }

  void setImage(Uint8List? bytes, {String? filename}) {
    imagePreviewBytes = bytes;
    imageFilename = filename;
    notifyListeners();
  }

  void resetAnalysisFlow() {
    step = AnalysisStep.idle;
    errorMessage = null;
    reportMarkdown = null;
    notifyListeners();
  }
}
