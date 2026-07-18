import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/terraguard_models.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common_widgets.dart';
import 'report_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.prediction});

  final PredictionResult prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          RiskBadge(
            nivel: prediction.riesgoTxt,
            confianza: prediction.confianza,
            large: true,
          ),
          if (prediction.visionMsg != null) ...[
            const SizedBox(height: 12),
            Text(
              prediction.visionMsg!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Probabilidades del modelo',
            icon: Icons.insights_outlined,
          ),
          const SizedBox(height: 12),
          ProbabilityList(probabilidades: prediction.probabilidades),
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Indicadores de campo',
            icon: Icons.grass_outlined,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SymptomBar(
                    label: 'Clorosis (amarillamiento)',
                    value: prediction.clorosisPct,
                    color: const Color(0xFFF9A825),
                    icon: Icons.wb_sunny_outlined,
                  ),
                  const SizedBox(height: 16),
                  SymptomBar(
                    label: 'Necrosis (manchas)',
                    value: prediction.necrosisPct,
                    color: const Color(0xFF6D4C41),
                    icon: Icons.bubble_chart_outlined,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              MetricTile(
                label: 'Distancia a mina',
                value: '${prediction.distKm.toStringAsFixed(1)} km',
                icon: Icons.factory_outlined,
              ),
              MetricTile(
                label: 'pH del suelo',
                value: prediction.ph.toStringAsFixed(1),
                icon: Icons.water_drop_outlined,
              ),
              MetricTile(
                label: 'Metal',
                value: prediction.metal,
                icon: Icons.science_outlined,
              ),
              MetricTile(
                label: 'Zona',
                value: prediction.zona.split(' ').first,
                icon: Icons.place_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<AnalysisProvider>().resetAnalysisFlow();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReportScreen(prediction: prediction),
                ),
              );
            },
            icon: const Icon(Icons.description_outlined),
            label: const Text('Ver reporte con IA'),
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
}
