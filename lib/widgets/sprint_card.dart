import 'package:flutter/material.dart';

import '../models/sprint.dart';
import '../utils/formatters.dart';
import 'sprint_status_chip.dart';

/// Sprint listesinde bir sprinti özetleyen yeniden kullanılabilir kart:
/// ad + durum rozeti, hedef, tarih aralığı ve story point ilerlemesi.
class SprintCard extends StatelessWidget {
  final Sprint sprint;

  /// Karta dokunulunca çağrılır; `null` ise kart dokunulamaz.
  final VoidCallback? onTap;

  const SprintCard({super.key, required this.sprint, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = sprint.totalStoryPoints;
    final completed = sprint.completedStoryPoints;
    final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sprint.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SprintStatusChip(status: sprint.status),
                ],
              ),
              if (sprint.goal != null && sprint.goal!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  sprint.goal!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      formatDateRange(sprint.startDate, sprint.endDate),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                formatStoryPoints(completed, total),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
