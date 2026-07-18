import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common_widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _center = LatLng(-16.6, -71.7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mapa de riesgo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focos mineros y muestras simuladas del dataset de Arequipa.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _LegendChip(color: AppColors.bajo, label: 'Bajo'),
                _LegendChip(color: AppColors.medio, label: 'Medio'),
                _LegendChip(color: AppColors.alto, label: 'Alto'),
                _LegendChip(color: Colors.red.shade700, label: 'Foco minero'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: provider.loadingMap && provider.mapPuntos.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        options: const MapOptions(
                          initialCenter: _center,
                          initialZoom: 8.2,
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.frontend_flit2026',
                          ),
                          CircleLayer(
                            circles: provider.mapPuntos
                                .map(
                                  (p) => CircleMarker(
                                    point: LatLng(p.lat, p.lon),
                                    radius: 5,
                                    color: colorFromHex(p.color),
                                    borderColor: Colors.white,
                                    borderStrokeWidth: 0.5,
                                    useRadiusInMeter: false,
                                  ),
                                )
                                .toList(),
                          ),
                          MarkerLayer(
                            markers: provider.mapFocos
                                .map(
                                  (f) => Marker(
                                    point: LatLng(f.lat, f.lon),
                                    width: 160,
                                    height: 56,
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.factory_rounded,
                                          color: Colors.red.shade700,
                                          size: 28,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surface,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            f.nombre.split(' ').first,
                                            style: theme.textTheme.labelSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
