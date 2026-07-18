import 'package:flutter/material.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({
    super.key,
    required this.stepLabel,
    this.subtitle,
  });

  final String stepLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Procesando')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(strokeWidth: 5),
              ),
              const SizedBox(height: 28),
              Text(
                stepLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
