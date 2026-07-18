import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/analysis_provider.dart';
import '../widgets/common_widgets.dart';
import 'analyze_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onStartAnalysis});

  final VoidCallback? onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.eco_rounded,
                  size: 36,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TerraGuard Arequipa',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tamizaje predictivo de metales pesados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'La cámara no ve el metal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detectamos el estrés visible de la planta (clorosis y necrosis), '
                    'lo cruzamos con geolocalización y pH del suelo, y un Random Forest '
                    'estima el riesgo Bajo / Medio / Alto para priorizar muestreo de laboratorio.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            title: '¿Cómo funciona?',
            subtitle: 'Cuatro pasos conectados con el backend del hackatón.',
            icon: Icons.route_rounded,
          ),
          const SizedBox(height: 12),
          const InfoCard(
            icon: Icons.photo_camera_outlined,
            title: '1. Visión con OpenCV',
            description:
                'Sube o captura una foto de la hoja para estimar clorosis y necrosis.',
          ),
          const InfoCard(
            icon: Icons.place_outlined,
            title: '2. Contexto geográfico',
            description:
                'Ubicación y zona de riesgo determinan la distancia al foco minero.',
          ),
          const InfoCard(
            icon: Icons.model_training_outlined,
            title: '3. Random Forest',
            description:
                'El modelo predice riesgo con probabilidades explicables.',
          ),
          const InfoCard(
            icon: Icons.auto_awesome_outlined,
            title: '4. Reporte con IA',
            description:
                'Gemini (o fallback local) recomienda biorremediación con plantas nativas.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<AnalysisProvider>().resetAnalysisFlow();
              if (onStartAnalysis != null) {
                onStartAnalysis!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AnalyzeScreen(),
                  ),
                );
              }
            },
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Analizar una hoja'),
          ),
        ],
      ),
    );
  }
}
