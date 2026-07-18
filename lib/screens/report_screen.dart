import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../models/terraguard_models.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common_widgets.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.prediction});

  final PredictionResult prediction;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final provider = context.read<AnalysisProvider>();
    final report = await provider.createReport(
      prediction: widget.prediction,
      apiKey: _apiKeyController.text.trim().isEmpty
          ? null
          : _apiKeyController.text.trim(),
    );
    if (!mounted) return;
    if (report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'No se pudo generar el reporte',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisProvider>();
    final theme = Theme.of(context);
    final report = provider.reportMarkdown;

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte IA')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          RiskBadge(
            nivel: widget.prediction.riesgoTxt,
            confianza: widget.prediction.confianza,
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Generar reporte',
            subtitle:
                'Gemini redacta recomendaciones de biorremediación. Sin API key se usa un fallback local igual de válido.',
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              labelText: 'API key de Gemini (opcional)',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: provider.generatingReport ? null : _generate,
            icon: provider.generatingReport
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.article_outlined),
            label: Text(
              provider.generatingReport ? 'Generando...' : 'Generar reporte',
            ),
          ),
          if (report != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: MarkdownBody(
                  data: report,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    h3: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    p: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
