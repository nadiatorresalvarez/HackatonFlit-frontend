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
    context.read<AnalysisProvider>().setImage(
          bytes,
          filename: file.name,
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de ubicación denegado. Se usará la zona seleccionada.'),
          ),
        );
        setState(() {
          _useGps = false;
          _lat = null;
          _lon = null;
          _locationLabel = null;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
        _locationLabel =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
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
    final zona = _selectedZone;
    if (zona == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una zona de riesgo.')),
      );
      return;
    }

    if (!_useManualSymptoms && provider.imagePreviewBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sube una foto o activa el modo manual de síntomas.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProcessingScreen(
          stepLabel: provider.imagePreviewBytes != null && !_useManualSymptoms
              ? 'Analizando imagen con visión artificial...'
              : 'Calculando riesgo con el modelo...',
          subtitle: 'Conectando con el backend TerraGuard',
        ),
      ),
    );

    final result = await provider.runAnalysis(
      zona: zona,
      ph: _ph,
      clorosisManual: _clorosisManual,
      necrosisManual: _necrosisManual,
      useManualSymptoms: _useManualSymptoms,
      lat: _useGps ? _lat : null,
      lon: _useGps ? _lon : null,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    if (result != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultsScreen(prediction: result),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = watchProvider(context);
    final theme = Theme.of(context);
    final zones = provider.zones;
    _selectedZone ??= zones.isNotEmpty ? zones.first.nombre : null;

    return Scaffold(
      appBar: widget.embedInShell
          ? null
          : AppBar(
              title: const Text('Analizar hoja'),
            ),
      body: provider.loadingZones && zones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const SectionHeader(
                  title: 'Datos de la parcela',
                  subtitle: 'Zona, pH del suelo y ubicación opcional.',
                  icon: Icons.agriculture_outlined,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedZone,
                  decoration: const InputDecoration(
                    labelText: 'Zona / foco de riesgo',
                  ),
                  items: zones
                      .map(
                        (RiskZone z) => DropdownMenuItem(
                          value: z.nombre,
                          child: Text(z.nombre, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedZone = value),
                ),
                if (_selectedZone != null) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final zone = zones.firstWhere((z) => z.nombre == _selectedZone);
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.science_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text('Metal de interés: ${zone.metal}'),
                          subtitle: Text(
                            'Referencia: ${zone.distKm.toStringAsFixed(1)} km al foco',
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Text('pH del suelo: ${_ph.toStringAsFixed(1)}'),
                Slider(
                  value: _ph,
                  min: 4,
                  max: 9,
                  divisions: 50,
                  label: _ph.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _ph = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usar mi ubicación GPS'),
                  subtitle: Text(
                    _locationLabel ?? 'Calcula distancia real al foco minero',
                  ),
                  value: _useGps,
                  onChanged: _locating
                      ? null
                      : (value) async {
                          setState(() => _useGps = value);
                          if (value) await _fetchLocation();
                        },
                ),
                const SizedBox(height: 8),
                const SectionHeader(
                  title: 'Foto de la hoja',
                  subtitle: 'OpenCV estimará clorosis y necrosis automáticamente.',
                  icon: Icons.eco_outlined,
                ),
                const SizedBox(height: 12),
                _PhotoPreview(bytes: provider.imagePreviewBytes),
                const SizedBox(height: 12),
                Row(
                  children: [
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
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ajustar síntomas manualmente'),
                  subtitle: const Text('Útil si no hay foto disponible'),
                  value: _useManualSymptoms,
                  onChanged: (value) => setState(() => _useManualSymptoms = value),
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
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: provider.processing ? null : _submit,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar análisis'),
                ),
              ],
            ),
    );
  }

  AnalysisProvider watchProvider(BuildContext context) =>
      context.watch<AnalysisProvider>();
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
                    Icon(
                      Icons.image_outlined,
                      size: 42,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin imagen seleccionada',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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
