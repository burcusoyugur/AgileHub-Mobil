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
