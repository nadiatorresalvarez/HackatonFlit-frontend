import 'package:flutter/material.dart';

import '../models/terraguard_models.dart';
import '../widgets/common_widgets.dart';
import 'report_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.assessment});
  final FullAssessmentResult assessment;

  @override
  Widget build(BuildContext context) {
    final pred = assessment.prediccion;
    final ind  = assessment.indicadores;
    final hr   = assessment.riesgoSalud;
    final ie   = assessment.impactoEconomico;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // ── Risk badge ────────────────────────────────────────────────────
          RiskBadge(
            nivel: pred.riesgoTxt,
            confianza: pred.confianza,
            large: true,
          ),
          const SizedBox(height: 8),
          if (pred.ubicacionOrigen != null)
            Center(
              child: Chip(
                avatar: Icon(
                  pred.ubicacionOrigen == 'GPS'
                      ? Icons.gps_fixed
                      : Icons.place_outlined,
                  size: 16,
                ),
                label: Text(
                  pred.ubicacionOrigen == 'GPS'
                      ? 'Zona auto-detectada por GPS'
                      : 'Zona seleccionada manualmente',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // ── Probabilidades ────────────────────────────────────────────────
          const SectionHeader(
              title: 'Probabilidades del modelo', icon: Icons.insights_outlined),
          const SizedBox(height: 10),
          ProbabilityList(probabilidades: pred.probabilidades),

          const SizedBox(height: 20),
          // ── Síntomas visuales ─────────────────────────────────────────────
          const SectionHeader(
              title: 'Síntomas visuales (OpenCV)',
              icon: Icons.eco_outlined),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                SymptomBar(
                  label: 'Clorosis (amarillamiento)',
                  value: pred.clorosisPct,
                  color: const Color(0xFFF9A825),
                  icon: Icons.wb_sunny_outlined,
                ),
                const SizedBox(height: 16),
                SymptomBar(
                  label: 'Necrosis (manchas)',
                  value: pred.necrosisPct,
                  color: const Color(0xFF6D4C41),
                  icon: Icons.bubble_chart_outlined,
                ),
              ]),
            ),
          ),

          const SizedBox(height: 16),
          // ── Datos básicos ─────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              MetricTile(
                label: 'Zona detectada',
                value: pred.zona.split(' ').take(2).join(' '),
                icon: Icons.factory_outlined,
              ),
              MetricTile(
                label: 'Distancia a mina',
                value: '${pred.distKm.toStringAsFixed(1)} km',
                icon: Icons.place_outlined,
              ),
              MetricTile(
                label: 'Metal principal',
                value: pred.metal,
                icon: Icons.science_outlined,
              ),
              MetricTile(
                label: 'pH del suelo',
                value: pred.ph.toStringAsFixed(1),
                icon: Icons.water_drop_outlined,
              ),
            ],
          ),

          if (pred.contaminantes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: pred.contaminantes
                  .map((c) => Chip(
                        label: Text(c,
                            style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 20),
          // ── Indicadores ambientales ───────────────────────────────────────
          const SectionHeader(
              title: 'Indicadores ambientales estimados',
              icon: Icons.monitor_heart_outlined),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _IndicatorTile(
                label: 'CE del suelo',
                value: '${ind.conductividadDs.toStringAsFixed(2)} dS/m',
                normal: '0.2–0.8',
                alert: ind.conductividadDs > 2.0,
                icon: Icons.electrical_services_outlined,
              ),
              _IndicatorTile(
                label: 'Materia orgánica',
                value: '${ind.materiaOrganicaPct.toStringAsFixed(2)}%',
                normal: '1.5–4.0%',
                alert: ind.materiaOrganicaPct < 1.0,
                icon: Icons.grass_outlined,
              ),
              _IndicatorTile(
                label: 'Turbidez agua',
                value: '${ind.turbidezNtu.toStringAsFixed(0)} NTU',
                normal: 'ECA: 100 NTU',
                alert: ind.turbidezNtu > 100,
                icon: Icons.water_outlined,
              ),
              _IndicatorTile(
                label: 'PM10 polvo mina',
                value: '${ind.pm10.toStringAsFixed(0)} μg/m³',
                normal: 'ECA 24h: 100',
                alert: ind.pm10 > 100,
                icon: Icons.air_outlined,
              ),
            ],
          ),
          if (ind.alertas.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...ind.alertas.map((a) => _AlertRow(text: a)),
          ],

          const SizedBox(height: 20),
          // ── Salud humana ──────────────────────────────────────────────────
          const SectionHeader(
              title: 'Riesgo para la salud (EPA RAGS)',
              icon: Icons.health_and_safety_outlined),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HriRow(
                    label: 'HRI (Health Risk Index)',
                    value: hr.hri.toStringAsFixed(3),
                    nivel: hr.hriNivel,
                    alert: hr.hri >= 1.0,
                    theme: theme,
                  ),
                  const Divider(height: 20),
                  _HriRow(
                    label: 'Riesgo carcinogénico',
                    value: _formatSci(hr.cancerRiskTotal),
                    nivel: hr.cancerRiskNivel,
                    alert: hr.cancerRiskTotal >= 1e-4,
                    theme: theme,
                  ),
                  const Divider(height: 20),
                  Text('Por metal:',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...hr.porMetal.entries.map((e) => _MetalRiskRow(
                        metal: e.key,
                        risk: e.value,
                        theme: theme,
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          // ── Impacto económico ─────────────────────────────────────────────
          const SectionHeader(
              title: 'Impacto económico (empresa minera)',
              icon: Icons.account_balance_outlined),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _EconRow(
                    label: 'Área agrícola en zona',
                    value: '${ie.totalHa.toStringAsFixed(0)} ha',
                    icon: Icons.landscape_outlined,
                  ),
                  _EconRow(
                    label: 'Valor producción/año',
                    value: 'USD ${_fmtUsd(ie.valorProduccionUsd)}',
                    icon: Icons.payments_outlined,
                  ),
                  _EconRow(
                    label: 'Pérdida estimada',
                    value: 'USD ${_fmtUsd(ie.perdidaUsd)} (${ie.fraccionPerdidaPct.toStringAsFixed(1)}%)',
                    icon: Icons.trending_down_outlined,
                    alert: true,
                  ),
                  const Divider(height: 20),
                  _EconRow(
                    label: 'Lab ICP-MS (${ie.muestrasLab} muestras)',
                    value: 'USD ${_fmtUsd(ie.costoLabUsd)}',
                    icon: Icons.biotech_outlined,
                  ),
                  _EconRow(
                    label: 'Fitorremediación (${ie.areaRemHa.toStringAsFixed(0)} ha)',
                    value: 'USD ${_fmtUsd(ie.costoFitoremedUsd)}',
                    icon: Icons.park_outlined,
                  ),
                  _EconRow(
                    label: 'Total acción correctiva',
                    value: 'USD ${_fmtUsd(ie.costoTotalUsd)}',
                    icon: Icons.build_outlined,
                    bold: true,
                  ),
                  const Divider(height: 20),
                  _EconRow(
                    label: 'Multa máx. OEFA',
                    value: 'USD ${_fmtUsd(ie.multaMaxOefaUsd)}',
                    icon: Icons.gavel_outlined,
                    alert: true,
                    bold: true,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_outlined,
                            size: 16, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ie.prioridadAccion,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          // ── Botones ───────────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ReportScreen(reportMarkdown: assessment.reporteMarkdown),
              ),
            ),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Ver reporte técnico completo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Nuevo análisis'),
          ),
        ],
      ),
    );
  }

  static String _fmtUsd(double v) {
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  static String _formatSci(double v) {
    if (v == 0) return '0';
    final exp = v.toString().contains('e')
        ? v.toStringAsExponential(2)
        : v.toStringAsExponential(2);
    return exp;
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({
    required this.label,
    required this.value,
    required this.normal,
    required this.alert,
    required this.icon,
  });
  final String label, value, normal;
  final bool alert;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert ? theme.colorScheme.error : theme.colorScheme.primary;
    return Card(
      color: alert
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(label,
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            Text(normal,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined,
              size: 14, color: theme.colorScheme.error),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}

class _HriRow extends StatelessWidget {
  const _HriRow({
    required this.label,
    required this.value,
    required this.nivel,
    required this.alert,
    required this.theme,
  });
  final String label, value, nivel;
  final bool alert;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = alert ? theme.colorScheme.error : theme.colorScheme.primary;
    return Row(
      children: [
        Icon(
          alert ? Icons.warning_amber_outlined : Icons.check_circle_outline,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              Text(value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w700)),
              Text(nivel,
                  style: theme.textTheme.bodySmall?.copyWith(color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetalRiskRow extends StatelessWidget {
  const _MetalRiskRow(
      {required this.metal, required this.risk, required this.theme});
  final String metal;
  final MetalRisk risk;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final alert = risk.hqTotal >= 1.0 || risk.alertaSuelo;
    final color =
        alert ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 8, top: 1),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text('$metal — ', style: theme.textTheme.bodySmall),
        Text(
          'HQ ${risk.hqTotal.toStringAsFixed(2)}  '
          '|  Cs ${risk.csEstimada.toStringAsFixed(0)} mg/kg '
          '(${risk.exceedanceSuelo.toStringAsFixed(1)}× ECA)',
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ]),
    );
  }
}

class _EconRow extends StatelessWidget {
  const _EconRow({
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
    this.bold = false,
  });
  final String label, value;
  final IconData icon;
  final bool alert, bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: theme.textTheme.bodySmall)),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}
