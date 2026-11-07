import 'package:flutter/material.dart';

import '../models/sprint.dart';
import '../theme/app_theme.dart';

/// Sprint durumunu renkli küçük bir rozetle gösterir.
class SprintStatusChip extends StatelessWidget {
  final SprintStatus status;

  const SprintStatusChip({super.key, required this.status});

  Color _color(BuildContext context) {
    switch (status) {
      case SprintStatus.planned:
        return AppTheme.todoColor;
      case SprintStatus.active:
        return AppTheme.inProgressColor;
      case SprintStatus.completed:
        return AppTheme.doneColor;
      case SprintStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
