import 'package:flutter/material.dart';

import '../config/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(icon, size: 18, color: theme.colorScheme.primary),
            if (icon != null) const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.nivel,
    required this.confianza,
    this.large = false,
  });

  final String nivel;
  final double confianza;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riesgo(nivel);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(large ? 20 : 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riesgo $nivel',
            style: (large
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.titleLarge)
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${confianza.toStringAsFixed(1)}% de confianza del modelo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class SymptomBar extends StatelessWidget {
  const SymptomBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            Text(label, style: theme.textTheme.titleSmall),
            const Spacer(),
            Text('${value.toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0, 1),
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
      ],
    );
  }
}

class ProbabilityList extends StatelessWidget {
  const ProbabilityList({super.key, required this.probabilidades});

  final Map<String, double> probabilidades;

  @override
  Widget build(BuildContext context) {
    final entries = probabilidades.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: entries.map((entry) {
        final color = AppColors.riesgo(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SymptomBar(
            label: entry.key,
            value: entry.value,
            color: color,
          ),
        );
      }).toList(),
    );
  }
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final value = int.parse('FF$cleaned', radix: 16);
  return Color(value);
}
