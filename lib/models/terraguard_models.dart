class RiskZone {
  const RiskZone({
    required this.nombre,
    required this.lat,
    required this.lon,
    required this.metal,
    required this.distKm,
  });

  factory RiskZone.fromJson(Map<String, dynamic> json) {
    return RiskZone(
      nombre: json['nombre'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      metal: json['metal'] as String,
      distKm: (json['dist_km'] as num).toDouble(),
    );
  }

  final String nombre;
  final double lat;
  final double lon;
  final String metal;
  final double distKm;
}

class VisionResult {
  const VisionResult({
    required this.clorosisPct,
    required this.necrosisPct,
    required this.ok,
    required this.msg,
  });

  factory VisionResult.fromJson(Map<String, dynamic> json) {
    return VisionResult(
      clorosisPct: (json['clorosis_pct'] as num).toDouble(),
      necrosisPct: (json['necrosis_pct'] as num).toDouble(),
      ok: json['ok'] as bool? ?? true,
      msg: json['msg'] as String? ?? '',
    );
  }

  final double clorosisPct;
  final double necrosisPct;
  final bool ok;
  final String msg;
}

class PredictionResult {
  const PredictionResult({
    required this.riesgoTxt,
    required this.riesgoNum,
    required this.confianza,
    required this.probabilidades,
    required this.zona,
    required this.metal,
    required this.distKm,
    required this.ph,
    required this.clorosisPct,
    required this.necrosisPct,
    required this.lat,
    required this.lon,
    required this.color,
    this.visionMsg,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final probsRaw = json['probabilidades'] as Map<String, dynamic>;
    return PredictionResult(
      riesgoTxt: json['riesgo_txt'] as String,
      riesgoNum: json['riesgo_num'] as int,
      confianza: (json['confianza'] as num).toDouble(),
      probabilidades: probsRaw.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      zona: json['zona'] as String,
      metal: json['metal'] as String,
      distKm: (json['dist_km'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      clorosisPct: (json['clorosis_pct'] as num).toDouble(),
      necrosisPct: (json['necrosis_pct'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      color: json['color'] as String? ?? '#2e7d32',
      visionMsg: json['vision_msg'] as String?,
    );
  }

  final String riesgoTxt;
  final int riesgoNum;
  final double confianza;
  final Map<String, double> probabilidades;
  final String zona;
  final String metal;
  final double distKm;
  final double ph;
  final double clorosisPct;
  final double necrosisPct;
  final double lat;
  final double lon;
  final String color;
  final String? visionMsg;
}

class MapSamplePoint {
  const MapSamplePoint({
    required this.lat,
    required this.lon,
    required this.riesgo,
    required this.color,
  });

  factory MapSamplePoint.fromJson(Map<String, dynamic> json) {
    return MapSamplePoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      riesgo: json['riesgo'] as String,
      color: json['color'] as String,
    );
  }

  final double lat;
  final double lon;
  final String riesgo;
  final String color;
}

class MapFocus {
  const MapFocus({
    required this.nombre,
    required this.lat,
    required this.lon,
  });

  factory MapFocus.fromJson(Map<String, dynamic> json) {
    return MapFocus(
      nombre: json['nombre'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  final String nombre;
  final double lat;
  final double lon;
}

class ModelMetrics {
  const ModelMetrics({
    required this.accuracy,
    required this.precisionMacro,
    required this.recallMacro,
    required this.f1Macro,
    required this.aucRoc,
    required this.matrizConfusion,
    required this.importancias,
  });

  factory ModelMetrics.fromJson(Map<String, dynamic> json) {
    final m = json['metricas'] as Map<String, dynamic>;
    final matriz = (m['matriz_confusion'] as List)
        .map((row) => (row as List).map((v) => v as int).toList())
        .toList();
    final impRaw = m['importancias'] as Map<String, dynamic>;
    return ModelMetrics(
      accuracy: (m['accuracy'] as num).toDouble(),
      precisionMacro: (m['precision_macro'] as num).toDouble(),
      recallMacro: (m['recall_macro'] as num).toDouble(),
      f1Macro: (m['f1_macro'] as num).toDouble(),
      aucRoc: (m['auc_roc'] as num).toDouble(),
      matrizConfusion: matriz,
      importancias: impRaw.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }

  final double accuracy;
  final double precisionMacro;
  final double recallMacro;
  final double f1Macro;
  final double aucRoc;
  final List<List<int>> matrizConfusion;
  final Map<String, double> importancias;
}
