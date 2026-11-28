import 'package:flutter/material.dart';

import '../models/sprint.dart';
import '../utils/formatters.dart';
import 'sprint_status_chip.dart';

/// Pano açılırken hangi sprintin seçileceğini belirler:
/// aktif sprint varsa o, yoksa başlangıcı en yakın planlanan sprint,
/// o da yoksa en son biten tamamlanmış sprint.
///
/// Hiç sprint yoksa (ya da yalnızca iptal edilmiş sprintler varsa) `null`
/// döner; pano bu durumda boş durumu gösterir.
int? defaultSprintId(List<Sprint> sprints) {
  for (final sprint in sprints) {
    if (sprint.isActive) return sprint.id;
  }

  Sprint? nearestPlanned;
  for (final sprint in sprints) {
    if (sprint.status != SprintStatus.planned) continue;
    if (nearestPlanned == null ||
        sprint.startDate.isBefore(nearestPlanned.startDate)) {
      nearestPlanned = sprint;
    }
  }
  if (nearestPlanned != null) return nearestPlanned.id;

  Sprint? lastCompleted;
  for (final sprint in sprints) {
    if (sprint.status != SprintStatus.completed) continue;
    if (lastCompleted == null ||
        sprint.endDate.isAfter(lastCompleted.endDate)) {
      lastCompleted = sprint;
    }
  }
  return lastCompleted?.id;
}

/// Seçim listesindeki sıra: aktif sprint en üstte, sonra planlananlar
/// (başlangıç tarihine göre), sonra tamamlananlar (en yeni önce),
/// en sonda iptal edilenler (en yeni önce). Gelen liste değiştirilmez.
List<Sprint> sortSprintsForPicker(List<Sprint> sprints) {
  int group(SprintStatus status) {
    switch (status) {
      case SprintStatus.active:
        return 0;
      case SprintStatus.planned:
        return 1;
      case SprintStatus.completed:
        return 2;
      case SprintStatus.cancelled:
        return 3;
    }
  }

  return [...sprints]..sort((a, b) {
    final byGroup = group(a.status).compareTo(group(b.status));
    if (byGroup != 0) return byGroup;
    if (a.status == SprintStatus.planned) {
      return a.startDate.compareTo(b.startDate);
    }
    // Aktif, tamamlanan ve iptal edilenlerde en yeni önce.
    final byEnd = b.endDate.compareTo(a.endDate);
    return byEnd != 0 ? byEnd : b.startDate.compareTo(a.startDate);
  });
}

/// Görev Panosu'nun app bar'ında başlık gibi duran sprint seçici.
///
/// Seçili sprintin adını ve durum rozetini gösterir; dokununca projenin
/// sprintleri alttan açılan bir listede gelir. Başka bir sprint seçilince
/// [onChanged] çağrılır, aynı sprint seçilirse ya da liste kapatılırsa
/// çağrılmaz.
class SprintPicker extends StatelessWidget {
  final List<Sprint> sprints;
  final int? selectedId;
  final ValueChanged<Sprint> onChanged;

  const SprintPicker({
    super.key,
    required this.sprints,
    required this.selectedId,
    required this.onChanged,
  });

  Sprint? get _selected {
    for (final sprint in sprints) {
      if (sprint.id == selectedId) return sprint;
    }
    return null;
  }

  Future<void> _openSheet(BuildContext context) async {
    final picked = await showModalBottomSheet<Sprint>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SprintSheet(
        sprints: sortSprintsForPicker(sprints),
        selectedId: selectedId,
      ),
    );
    if (picked != null && picked.id != selectedId) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    final enabled = sprints.isNotEmpty;

    return Semantics(
      button: true,
      enabled: enabled,
      label: selected == null
          ? 'Sprint seç'
          : 'Seçili sprint: ${selected.name}, ${selected.status.label}. '
                'Değiştirmek için dokun',
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? () => _openSheet(context) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  selected?.name ?? (enabled ? 'Sprint seç' : 'Sprint yok'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      theme.appBarTheme.titleTextStyle ??
                      theme.textTheme.titleLarge,
                ),
              ),
              if (selected != null) ...[
                const SizedBox(width: 8),
                SprintStatusChip(status: selected.status),
              ],
              if (enabled) const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alttan açılan sprint listesi; seçilen sprintle kapanır.
class _SprintSheet extends StatelessWidget {
  final List<Sprint> sprints;
  final int? selectedId;

  const _SprintSheet({required this.sprints, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Sprint seç', style: theme.textTheme.titleMedium),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sprints.length,
              itemBuilder: (context, index) {
                final sprint = sprints[index];
                final isSelected = sprint.id == selectedId;
                final cancelled = sprint.status == SprintStatus.cancelled;

                return Opacity(
                  // İptal edilen sprintler seçilebilir ama soluk görünür.
                  opacity: cancelled ? 0.5 : 1,
                  child: ListTile(
                    selected: isSelected,
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? colors.primary : colors.outline,
                    ),
                    title: Text(
                      sprint.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      formatDateRange(sprint.startDate, sprint.endDate),
                    ),
                    trailing: SprintStatusChip(status: sprint.status),
                    onTap: () => Navigator.of(context).pop(sprint),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
