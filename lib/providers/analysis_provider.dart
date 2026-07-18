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

  AnalysisStep step = AnalysisStep.idle;
  String? errorMessage;

  // Resultado completo — incluye predicción + indicadores + salud + económico + reporte
  FullAssessmentResult? lastAssessment;

  // Accesos directos para no cambiar demasiado en pantallas existentes
  PredictionResult? get lastPrediction => lastAssessment?.prediccion;
  String? get reportMarkdown => lastAssessment?.reporteMarkdown;

  Uint8List? imagePreviewBytes;
  String? imageFilename;

  Future<void> bootstrap() async {
    await Future.wait([loadZones(), loadMetrics(), loadMapData()]);
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
    } finally {
      loadingMap = false;
      notifyListeners();
    }
  }

  /// Ejecuta el análisis completo en una sola llamada a /api/full-assessment.
  /// Si hay imagen seleccionada la analiza primero con /api/analyze-image.
  /// [zona] es opcional cuando se proporcionan [lat] y [lon] (auto-detect GPS).
  Future<FullAssessmentResult?> runAnalysis({
    String? zona,
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
    lastAssessment = null;
    notifyListeners();

    try {
      double clorosis = clorosisManual;
      double necrosis = necrosisManual;

      // Paso 1 — análisis de imagen si hay foto
      if (!useManualSymptoms && imagePreviewBytes != null) {
        final vision = await _api.analyzeImage(
          bytes: imagePreviewBytes!,
          filename: imageFilename ?? 'hoja.jpg',
        );
        clorosis = vision.clorosisPct;
        necrosis = vision.necrosisPct;
      }

      // Paso 2 — evaluación completa (predicción + salud + económico + reporte)
      step = AnalysisStep.predicting;
      notifyListeners();

      final result = await _api.fullAssessment(
        ph: ph,
        clorosisPct: clorosis,
        necrosisPct: necrosis,
        zona: zona,
        lat: lat,
        lon: lon,
      );

      lastAssessment = result;
      step = AnalysisStep.done;
      return result;
    } catch (e) {
      step = AnalysisStep.error;
      errorMessage = e.toString();
      return null;
    } finally {
      processing = false;
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
    lastAssessment = null;
    notifyListeners();
  }
}
