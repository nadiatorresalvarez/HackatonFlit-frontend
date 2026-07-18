import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/analysis_provider.dart';
import '../widgets/common_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AnalysisProvider>();
    final metrics = provider.metrics;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Sobre el proyecto',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'TerraGuard Arequipa es un tamizaje predictivo de riesgo de contaminación '
            'por metales pesados en la agricultura de Arequipa. No reemplaza el laboratorio: '
            'prioriza qué parcelas analizar primero para reducir costos.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Stack técnico',
            icon: Icons.layers_outlined,
          ),
          const SizedBox(height: 12),
          const InfoCard(
            icon: Icons.visibility_outlined,
            title: 'Visión — OpenCV',
            description: 'Segmentación HSV para clorosis y necrosis en hojas.',
          ),
          const InfoCard(
            icon: Icons.forest_outlined,
            title: 'Modelo — Random Forest',
            description: 'Features: clorosis, necrosis, distancia a mina y pH.',
          ),
          const InfoCard(
            icon: Icons.psychology_outlined,
            title: 'Reporte — Gemini + fallback',
            description: 'Biorremediación con Baccharis, totora y plantas nativas.',
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Métricas del modelo',
            subtitle: 'Obtenidas del backend al entrenar el Random Forest.',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 12),
          if (provider.loadingMetrics && metrics == null)
            const Center(child: CircularProgressIndicator())
          else if (metrics == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudieron cargar las métricas. Verifica que el backend esté activo.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                MetricTile(
                  label: 'Accuracy',
                  value: metrics.accuracy.toStringAsFixed(3),
                ),
                MetricTile(
                  label: 'F1 macro',
                  value: metrics.f1Macro.toStringAsFixed(3),
                ),
                MetricTile(
                  label: 'AUC ROC',
                  value: metrics.aucRoc.toStringAsFixed(3),
                ),
                MetricTile(
                  label: 'Precision',
                  value: metrics.precisionMacro.toStringAsFixed(3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Matriz de confusión', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _ConfusionTable(matrix: metrics.matrizConfusion),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Importancia de variables',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    ...metrics.importancias.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SymptomBar(
                          label: e.key,
                          value: e.value * 100,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tamizaje preliminar de apoyo a la decisión. No reemplaza análisis '
                'de laboratorio certificado (EPA 6020 / ICP-MS). Datos sintéticos '
                'calibrados con rangos de estudios reales de Arequipa.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfusionTable extends StatelessWidget {
  const _ConfusionTable({required this.matrix});

  final List<List<int>> matrix;

  @override
  Widget build(BuildContext context) {
    const labels = ['Bajo', 'Medio', 'Alto'];
    return Table(
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      defaultColumnWidth: const FlexColumnWidth(),
      children: [
        TableRow(
          children: [
            const SizedBox(),
            ...labels.map((l) => _Cell(text: l, header: true)),
          ],
        ),
        for (var i = 0; i < matrix.length; i++)
          TableRow(
            children: [
              _Cell(text: labels[i], header: true),
              ...matrix[i].map((v) => _Cell(text: '$v')),
            ],
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.text, this.header = false});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: header ? FontWeight.w700 : FontWeight.w400,
            ),
      ),
    );
  }
}
