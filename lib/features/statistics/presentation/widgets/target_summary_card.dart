import 'package:flutter/material.dart';

/// The status of a target comparison for a single period.
enum TargetStatus { under, onTarget, over, noTarget }

TargetStatus classifyTarget(double consumed, double target) {
  if (target <= 0) return TargetStatus.noTarget;
  // ±5% of the target counts as "on target".
  final ratio = consumed / target;
  if (ratio < 0.95) return TargetStatus.under;
  if (ratio <= 1.05) return TargetStatus.onTarget;
  return TargetStatus.over;
}

/// A single totals card that compares a period's consumed calories to the
/// period's target. Shows the value, the target, a status chip, and a thin
/// progress bar (green under target, red over).
class TargetSummaryCard extends StatelessWidget {
  const TargetSummaryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.consumed,
    required this.target,
  });

  final String label;
  final IconData icon;
  final double consumed;
  final double target;

  @override
  Widget build(BuildContext context) {
    final status = classifyTarget(consumed, target);
    final colorScheme = Theme.of(context).colorScheme;
    final progressColor = switch (status) {
      TargetStatus.under => Colors.green.shade600,
      TargetStatus.onTarget => Colors.green.shade700,
      TargetStatus.over => colorScheme.error,
      TargetStatus.noTarget => colorScheme.outline,
    };

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                _StatusChip(status: status, consumed: consumed, target: target),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  consumed.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 6),
                Text(
                  target > 0 ? '/ ${target.toStringAsFixed(0)} kcal' : 'kcal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: target > 0 ? (consumed / target).clamp(0.0, 1.5) : 0,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.consumed,
    required this.target,
  });

  final TargetStatus status;
  final double consumed;
  final double target;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TargetStatus.under => (
          'Under by ${(target - consumed).toStringAsFixed(0)}',
          Colors.green.shade100,
        ),
      TargetStatus.onTarget => ('On target', Colors.green.shade100),
      TargetStatus.over => (
          'Over by ${(consumed - target).toStringAsFixed(0)}',
          Theme.of(context).colorScheme.errorContainer,
        ),
      TargetStatus.noTarget => ('No target set', Colors.grey.shade200),
    };
    final textColor = status == TargetStatus.over
        ? Theme.of(context).colorScheme.onErrorContainer
        : status == TargetStatus.noTarget
            ? Colors.grey.shade700
            : Colors.green.shade900;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
