import '../models/sprint.dart';

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
