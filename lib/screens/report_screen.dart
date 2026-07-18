import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.reportMarkdown});
  final String reportMarkdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte técnico')),
      body: Markdown(
        data: reportMarkdown,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          h1: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
          h2: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
          h3: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
          p: theme.textTheme.bodyMedium,
          tableHead: theme.textTheme.labelSmall
              ?.copyWith(fontWeight: FontWeight.w700),
          tableBody: theme.textTheme.bodySmall,
          tableBorder: TableBorder.all(
              color: theme.colorScheme.outlineVariant, width: 0.5),
          blockquoteDecoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                  color: theme.colorScheme.primary, width: 3),
            ),
          ),
          codeblockDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
