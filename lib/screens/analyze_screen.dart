import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/terraguard_models.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common_widgets.dart';
import 'processing_screen.dart';
import 'results_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key, this.embedInShell = false});
  final bool embedInShell;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _picker = ImagePicker();

  String? _selectedZone;
  double _ph = 6.5;
  double _clorosisManual = 30;
  double _necrosisManual = 15;
  bool _useManualSymptoms = false;
  bool _useGps = false;
  double? _lat;
  double? _lon;
  String? _locationLabel;
  bool _locating = false;

  // Con GPS activo la zona es opcional — el backend la auto-detecta
  bool get _zoneRequired => !(_useGps && _lat != null && _lon != null);

  @override
  void initState() {
    super.initState();
    final provider = context.read<AnalysisProvider>();
    if (provider.zones.isNotEmpty) {
      _selectedZone = provider.zones.first.nombre;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    context.read<AnalysisProvider>().setImage(bytes, filename: file.name);
    setState(() => _useManualSymptoms = false);
  }

  Future<void> _fetchLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Permiso de ubicación denegado — se usará la zona seleccionada.'),
        ));
        setState(() {
          _useGps = false;
          _lat = _lon = null;
          _locationLabel = null;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lon = pos.longitude;
        _locationLabel =
            '${pos.latitude.toStringAsFixed(4)}°, ${pos.longitude.toStringAsFixed(4)}°';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener ubicación: $e')),
      );
      setState(() => _useGps = false);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submit() async {
    final provider = context.read<AnalysisProvider>();

    // Validación: necesita zona O GPS
    if (_zoneRequired && _selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una zona o activa el GPS.')),
      );
      return;
    }

    if (!_useManualSymptoms && provider.imagePreviewBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sube una foto o activa el modo manual de síntomas.'),
      ));
      return;
    }

    if (!mounted) return;

    final label = provider.imagePreviewBytes != null && !_useManualSymptoms
        ? 'Analizando imagen con visión artificial...'
        : 'Calculando riesgo con el modelo...';

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ProcessingScreen(
        stepLabel: label,
        subtitle: _useGps && _lat != null
            ? 'GPS: $_locationLabel → detectando zona automáticamente'
            : 'Zona: ${_selectedZone ?? "—"}',
      ),
    ));

    final result = await provider.runAnalysis(
      zona: _zoneRequired ? _selectedZone : null,
      ph: _ph,
      clorosisManual: _clorosisManual,
      necrosisManual: _necrosisManual,
      useManualSymptoms: _useManualSymptoms,
      lat: _useGps ? _lat : null,
      lon: _useGps ? _lon : null,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // quita ProcessingScreen

    if (result != null) {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ResultsScreen(assessment: result),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisProvider>();
    final theme = Theme.of(context);
    final zones = provider.zones;
    _selectedZone ??= zones.isNotEmpty ? zones.first.nombre : null;
    final gpsActive = _useGps && _lat != null;

    return Scaffold(
      appBar: widget.embedInShell ? null : AppBar(title: const Text('Analizar')),
      body: provider.loadingZones && zones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // ── Zona / GPS ──────────────────────────────────────────────
                const SectionHeader(
                  title: 'Ubicación de la parcela',
                  subtitle: 'Usa GPS para detección automática de zona o selecciona manualmente.',
                  icon: Icons.place_outlined,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usar mi ubicación GPS'),
                  subtitle: Text(
                    gpsActive
                        ? '📍 $_locationLabel — zona se detectará automáticamente'
                        : _locating
                            ? 'Obteniendo ubicación...'
                            : 'Calcula distancia real al foco minero más cercano',
                    style: TextStyle(
                      color: gpsActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          gpsActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  value: _useGps,
                  onChanged: _locating
                      ? null
                      : (value) async {
                          setState(() => _useGps = value);
                          if (value) await _fetchLocation();
                        },
                ),
                if (!gpsActive) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedZone,
                    decoration: const InputDecoration(
                      labelText: 'Zona / foco de riesgo (fallback sin GPS)',
                    ),
                    items: zones
                        .map((RiskZone z) => DropdownMenuItem(
                              value: z.nombre,
                              child: Text(z.nombre,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedZone = v),
                  ),
                  if (_selectedZone != null && zones.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final zone =
                          zones.firstWhere((z) => z.nombre == _selectedZone,
                              orElse: () => zones.first);
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.science_outlined,
                              color: theme.colorScheme.primary),
                          title: Text('Metal: ${zone.metal}'),
                          subtitle: Text(
                            zone.contaminantes.isNotEmpty
                                ? 'Contaminantes: ${zone.contaminantes.join(", ")}'
                                : 'Ref: ${zone.distKm.toStringAsFixed(1)} km al foco',
                          ),
                          trailing: zone.descripcion != null
                              ? Tooltip(
                                  message: zone.descripcion!,
                                  child: const Icon(Icons.info_outline,
                                      size: 18),
                                )
                              : null,
                        ),
                      );
                    }),
                  ],
                ] else ...[
                  const SizedBox(height: 4),
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.gps_fixed,
                              color: theme.colorScheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'La zona minera más cercana se detectará automáticamente.',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── pH ──────────────────────────────────────────────────────
                const SizedBox(height: 16),
                const SectionHeader(
                  title: 'Parámetros del suelo',
                  icon: Icons.agriculture_outlined,
                ),
                const SizedBox(height: 8),
                Text('pH del suelo: ${_ph.toStringAsFixed(1)}'),
                Slider(
                  value: _ph,
                  min: 4,
                  max: 9,
                  divisions: 50,
                  label: _ph.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _ph = v),
                ),
                Text(
                  _ph > 7.5
                      ? '⚠️ pH alcalino — mayor movilidad del arsénico'
                      : _ph < 6.2
                          ? '⚠️ pH ácido — mayor movilidad de Cu/Pb/Zn'
                          : '✅ pH neutro — movilidad moderada',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (_ph > 7.5 || _ph < 6.2)
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                // ── Foto ────────────────────────────────────────────────────
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Foto de la hoja',
                  subtitle: 'OpenCV (ExG+HSV+CIELAB) estima clorosis y necrosis automáticamente.',
                  icon: Icons.eco_outlined,
                ),
                const SizedBox(height: 12),
                _PhotoPreview(bytes: provider.imagePreviewBytes),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galería'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Cámara'),
                    ),
                  ),
                ]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Síntomas manuales'),
                  subtitle: const Text('Útil si no hay foto disponible'),
                  value: _useManualSymptoms,
                  onChanged: (v) => setState(() => _useManualSymptoms = v),
                ),
                if (_useManualSymptoms) ...[
                  Text('Clorosis: ${_clorosisManual.round()}%'),
                  Slider(
                    value: _clorosisManual,
                    max: 100,
                    divisions: 100,
                    label: _clorosisManual.round().toString(),
                    onChanged: (v) => setState(() => _clorosisManual = v),
                  ),
                  Text('Necrosis: ${_necrosisManual.round()}%'),
                  Slider(
                    value: _necrosisManual,
                    max: 100,
                    divisions: 100,
                    label: _necrosisManual.round().toString(),
                    onChanged: (v) => setState(() => _necrosisManual = v),
                  ),
                ],

                // ── Botón ───────────────────────────────────────────────────
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: provider.processing ? null : _submit,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar análisis completo'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Incluye predicción · indicadores · riesgo de salud · impacto económico · reporte',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({this.bytes});
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: bytes == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        size: 42,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('Sin imagen seleccionada',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(bytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
