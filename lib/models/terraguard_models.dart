// ─────────────────────────────────────────────────────────────────────────────
// terraguard_models.dart — Modelos de datos TerraGuard Arequipa v3.0
// ─────────────────────────────────────────────────────────────────────────────

class RiskZone {
  const RiskZone({
    required this.nombre,
    required this.lat,
    required this.lon,
    required this.metal,
    required this.distKm,
    this.contaminantes = const [],
    this.descripcion,
  });

  factory RiskZone.fromJson(Map<String, dynamic> json) => RiskZone(
        nombre: json['nombre'] as String,
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
        metal: json['metal'] as String,
        distKm: (json['dist_agr_mina_km'] as num? ?? json['dist_km'] as num? ?? 0).toDouble(),
        contaminantes: (json['contaminantes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        descripcion: json['descripcion'] as String?,
      );

  final String nombre;
  final double lat;
  final double lon;
  final String metal;
  final double distKm;
  final List<String> contaminantes;
  final String? descripcion;
}

// ─── Visión computacional ────────────────────────────────────────────────────
class VisionResult {
  const VisionResult({
    required this.clorosisPct,
    required this.necrosisPct,
    required this.ok,
    required this.msg,
  });

  factory VisionResult.fromJson(Map<String, dynamic> json) => VisionResult(
        clorosisPct: (json['clorosis_pct'] as num).toDouble(),
        necrosisPct: (json['necrosis_pct'] as num).toDouble(),
        ok: json['ok'] as bool? ?? true,
        msg: json['msg'] as String? ?? '',
      );

  final double clorosisPct;
  final double necrosisPct;
  final bool ok;
  final String msg;
}

// ─── Predicción básica (usada dentro de FullAssessmentResult) ────────────────
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
    this.contaminantes = const [],
    this.ubicacionOrigen,
    this.visionMsg,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final probsRaw = json['probabilidades'] as Map<String, dynamic>? ?? {};
    return PredictionResult(
      riesgoTxt: json['riesgo_txt'] as String,
      riesgoNum: json['riesgo_num'] as int,
      confianza: (json['confianza'] as num).toDouble(),
      probabilidades: probsRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      zona: json['zona'] as String,
      metal: json['metal'] as String,
      distKm: (json['dist_km'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      clorosisPct: (json['clorosis_pct'] as num).toDouble(),
      necrosisPct: (json['necrosis_pct'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      color: json['color'] as String? ?? '#2e7d32',
      contaminantes: (json['contaminantes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ubicacionOrigen: json['ubicacion_origen'] as String?,
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
  final List<String> contaminantes;
  final String? ubicacionOrigen;
  final String? visionMsg;
}

// ─── Indicadores ambientales ─────────────────────────────────────────────────
class IndicatorsResult {
  const IndicatorsResult({
    required this.conductividadDs,
    required this.materiaOrganicaPct,
    required this.turbidezNtu,
    required this.pm10,
    required this.alertas,
  });

  factory IndicatorsResult.fromJson(Map<String, dynamic> json) => IndicatorsResult(
        conductividadDs:
            (json['conductividad_electrica_ds_m'] as num).toDouble(),
        materiaOrganicaPct: (json['materia_organica_pct'] as num).toDouble(),
        turbidezNtu: (json['turbidez_agua_ntu'] as num).toDouble(),
        pm10: (json['pm10_ug_m3'] as num).toDouble(),
        alertas: (json['alertas'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  final double conductividadDs;
  final double materiaOrganicaPct;
  final double turbidezNtu;
  final double pm10;
  final List<String> alertas;
}

// ─── Riesgo para la salud (EPA RAGS) ─────────────────────────────────────────
class MetalRisk {
  const MetalRisk({
    required this.metal,
    required this.csEstimada,
    required this.cwEstimada,
    required this.hqTotal,
    required this.exceedanceSuelo,
    required this.exceedanceAgua,
    required this.alertaSuelo,
    required this.alertaAgua,
    this.cancerRisk,
  });

  factory MetalRisk.fromJson(String metal, Map<String, dynamic> json) =>
      MetalRisk(
        metal: metal,
        csEstimada: (json['cs_estimada_mg_kg'] as num).toDouble(),
        cwEstimada: (json['cw_estimada_mg_l'] as num).toDouble(),
        hqTotal: (json['hq_total'] as num).toDouble(),
        exceedanceSuelo: (json['exceedance_eca_suelo'] as num).toDouble(),
        exceedanceAgua: (json['exceedance_eca_agua'] as num).toDouble(),
        alertaSuelo: json['alerta_suelo'] as bool? ?? false,
        alertaAgua: json['alerta_agua'] as bool? ?? false,
        cancerRisk: json['cancer_risk'] != null
            ? (json['cancer_risk'] as num).toDouble()
            : null,
      );

  final String metal;
  final double csEstimada;
  final double cwEstimada;
  final double hqTotal;
  final double exceedanceSuelo;
  final double exceedanceAgua;
  final bool alertaSuelo;
  final bool alertaAgua;
  final double? cancerRisk;
}

class HealthRiskResult {
  const HealthRiskResult({
    required this.hri,
    required this.hriNivel,
    required this.cancerRiskTotal,
    required this.cancerRiskNivel,
    required this.porMetal,
  });

  factory HealthRiskResult.fromJson(Map<String, dynamic> json) {
    final rawMetal =
        json['por_metal'] as Map<String, dynamic>? ?? {};
    return HealthRiskResult(
      hri: (json['hri'] as num).toDouble(),
      hriNivel: json['hri_nivel'] as String,
      cancerRiskTotal: (json['cancer_risk_total'] as num).toDouble(),
      cancerRiskNivel: json['cancer_risk_nivel'] as String,
      porMetal: rawMetal.map(
        (k, v) => MapEntry(k, MetalRisk.fromJson(k, v as Map<String, dynamic>)),
      ),
    );
  }

  final double hri;
  final String hriNivel;
  final double cancerRiskTotal;
  final String cancerRiskNivel;
  final Map<String, MetalRisk> porMetal;
}

// ─── Impacto económico ────────────────────────────────────────────────────────
class EconomicImpactResult {
  const EconomicImpactResult({
    required this.totalHa,
    required this.valorProduccionUsd,
    required this.fraccionPerdidaPct,
    required this.perdidaUsd,
    required this.muestrasLab,
    required this.costoLabUsd,
    required this.areaRemHa,
    required this.costoFitoremedUsd,
    required this.costoTotalUsd,
    required this.multaMaxOefaUsd,
    required this.prioridadAccion,
  });

  factory EconomicImpactResult.fromJson(Map<String, dynamic> json) {
    final area = json['area_agricola_influencia'] as Map<String, dynamic>;
    final imp  = json['impacto_estimado']         as Map<String, dynamic>;
    final cos  = json['costos_accion']             as Map<String, dynamic>;
    final reg  = json['exposicion_regulatoria']    as Map<String, dynamic>;
    return EconomicImpactResult(
      totalHa:           (area['total_ha'] as num).toInt(),
      valorProduccionUsd:(area['valor_produccion_anual_usd'] as num).toDouble(),
      fraccionPerdidaPct:(imp['fraccion_perdida_pct'] as num).toDouble(),
      perdidaUsd:        (imp['perdida_produccion_usd'] as num).toDouble(),
      muestrasLab:       (cos['muestras_icp_ms'] as num).toInt(),
      costoLabUsd:       (cos['costo_laboratorio_usd'] as num).toDouble(),
      areaRemHa:         (cos['area_fitorremediacion_ha'] as num).toDouble(),
      costoFitoremedUsd: (cos['costo_fitorremediacion_usd'] as num).toDouble(),
      costoTotalUsd:     (cos['costo_total_usd'] as num).toDouble(),
      multaMaxOefaUsd:   (reg['multa_max_oefa_usd'] as num).toDouble(),
      prioridadAccion:   json['prioridad_accion'] as String,
    );
  }

  final int totalHa;
  final double valorProduccionUsd;
  final double fraccionPerdidaPct;
  final double perdidaUsd;
  final int muestrasLab;
  final double costoLabUsd;
  final double areaRemHa;
  final double costoFitoremedUsd;
  final double costoTotalUsd;
  final double multaMaxOefaUsd;
  final String prioridadAccion;
}

// ─── Resultado completo (full-assessment) ────────────────────────────────────
class FullAssessmentResult {
  const FullAssessmentResult({
    required this.prediccion,
    required this.indicadores,
    required this.riesgoSalud,
    required this.impactoEconomico,
    required this.reporteMarkdown,
  });

  factory FullAssessmentResult.fromJson(Map<String, dynamic> json) =>
      FullAssessmentResult(
        prediccion:       PredictionResult.fromJson(
            json['prediccion'] as Map<String, dynamic>),
        indicadores:      IndicatorsResult.fromJson(
            json['indicadores_ambientales'] as Map<String, dynamic>),
        riesgoSalud:      HealthRiskResult.fromJson(
            json['riesgo_salud'] as Map<String, dynamic>),
        impactoEconomico: EconomicImpactResult.fromJson(
            json['impacto_economico'] as Map<String, dynamic>),
        reporteMarkdown:  json['reporte_markdown'] as String,
      );

  final PredictionResult prediccion;
  final IndicatorsResult indicadores;
  final HealthRiskResult riesgoSalud;
  final EconomicImpactResult impactoEconomico;
  final String reporteMarkdown;
}

// ─── Mapa ────────────────────────────────────────────────────────────────────
class MapSamplePoint {
  const MapSamplePoint({
    required this.lat,
    required this.lon,
    required this.riesgo,
    required this.color,
  });

  factory MapSamplePoint.fromJson(Map<String, dynamic> json) => MapSamplePoint(
        lat:    (json['lat'] as num).toDouble(),
        lon:    (json['lon'] as num).toDouble(),
        riesgo: json['riesgo'] as String,
        color:  json['color'] as String,
      );

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
    this.metal,
  });

  factory MapFocus.fromJson(Map<String, dynamic> json) => MapFocus(
        nombre: json['nombre'] as String,
        lat:    (json['lat'] as num).toDouble(),
        lon:    (json['lon'] as num).toDouble(),
        metal:  json['metal'] as String?,
      );

  final String nombre;
  final double lat;
  final double lon;
  final String? metal;
}

// ─── Métricas del modelo ─────────────────────────────────────────────────────
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
      accuracy:       (m['accuracy'] as num).toDouble(),
      precisionMacro: (m['precision_macro'] as num).toDouble(),
      recallMacro:    (m['recall_macro'] as num).toDouble(),
      f1Macro:        (m['f1_macro'] as num).toDouble(),
      aucRoc:         (m['auc_roc'] as num).toDouble(),
      matrizConfusion: matriz,
      importancias: impRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
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
