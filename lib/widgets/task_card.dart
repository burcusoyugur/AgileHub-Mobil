import 'package:flutter/material.dart';

import '../models/task.dart';

/// Görev Panosu'ndaki ve Görevlerim ekranındaki görev kartı.
///
/// Sol kenardaki şerit ve öncelik etiketi görevin önceliğini gösterir. Renkler
/// temadan alındığı için açık ve koyu temada okunaklıdır.
class TaskCard extends StatelessWidget {
  final Task task;

  /// Kartın tamamına dokununca çağrılır (ör. görev detayına gitmek için).
  final VoidCallback? onTap;

  /// Sağ üstteki "Durumu değiştir" düğmesi. `null` ise düğme görünmez.
  final VoidCallback? onStatusTap;

  const TaskCard({super.key, required this.task, this.onTap, this.onStatusTap});

  static Color priorityColor(ColorScheme colors, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return colors.error;
      case TaskPriority.high:
        return colors.secondary;
      case TaskPriority.medium:
        return colors.primary;
      case TaskPriority.low:
        return colors.outline;
    }
  }

  /// Ekran okuyucunun kartı tek cümle olarak okuması için.
  String get _semanticLabel {
    final parts = [
      task.title,
      '${task.priority.label} öncelik',
      if (task.storyPoints != null) '${task.storyPoints} story point',
      task.assignedUserName ?? 'Atanmamış',
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final priority = priorityColor(colors, task.priority);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true,
        button: onTap != null,
        label: _semanticLabel,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  key: const ValueKey('task-card-priority-bar'),
                  width: 4,
                  color: priority,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      12,
                      onStatusTap == null ? 12 : 4,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ExcludeSemantics(
                                child: Text(
                                  task.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            if (onStatusTap != null)
                              IconButton(
                                icon: const Icon(Icons.swap_horiz),
                                tooltip: 'Durumu değiştir',
                                visualDensity: VisualDensity.compact,
                                onPressed: onStatusTap,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ExcludeSemantics(
                          child: _MetaRow(task: task, priorityColor: priority),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartın alt satırı: öncelik etiketi, story point ve atanan kişi.
class _MetaRow extends StatelessWidget {
  final Task task;
  final Color priorityColor;

  const _MetaRow({required this.task, required this.priorityColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(text: task.priority.label, color: priorityColor, filled: true),
        if (task.storyPoints case final points?) ...[
          const SizedBox(width: 6),
          _Pill(
            text: '$points SP',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
        const SizedBox(width: 12),
        // Uzun adlar dar ekranda taşmasın, etiketler her zaman görünsün.
        Flexible(child: _Assignee(name: task.assignedUserName)),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const _Pill({required this.text, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.15) : null,
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Assignee extends StatelessWidget {
  final String? name;

  const _Assignee({required this.name});

  /// Dart'ın `toUpperCase`'i Türkçe i'yi "I" yaptığı için elle çevrilir.
  static String _initial(String name) {
    final first = name.characters.first;
    if (first == 'i') return 'İ';
    if (first == 'ı') return 'I';
    return first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);
    final assignee = name?.trim();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (assignee == null || assignee.isEmpty)
          Icon(Icons.person_off_outlined, size: 16, color: colors.outline)
        else
          CircleAvatar(
            radius: 9,
            backgroundColor: colors.primaryContainer,
            child: Text(
              _initial(assignee),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            (assignee == null || assignee.isEmpty) ? 'Atanmamış' : assignee,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
