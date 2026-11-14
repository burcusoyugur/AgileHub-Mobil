import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/data/sample_data.dart';
import 'package:agilehub_mobil/models/sprint.dart';
import 'package:agilehub_mobil/models/task.dart';

/// Örnek verinin web'deki demo verisiyle aynı kurallara uyduğunu denetler.
void main() {
  final tasks = SampleData.tasks;

  int storyPoints(Iterable<Task> list) =>
      list.fold(0, (sum, t) => sum + (t.storyPoints ?? 0));

  test('görev kimlikleri benzersiz', () {
    final ids = tasks.map((t) => t.id).toSet();
    expect(ids, hasLength(tasks.length));
  });

  test('sprint story point toplamları görevlerle tutarlı', () {
    for (final sprint in SampleData.sprints) {
      final sprintTasks = tasks.where((t) => t.sprintId == sprint.id);
      final done = sprintTasks.where((t) => t.status == TaskStatus.done);

      expect(
        storyPoints(sprintTasks),
        sprint.totalStoryPoints,
        reason: '${sprint.name} (id ${sprint.id}) toplam SP',
      );
      expect(
        storyPoints(done),
        sprint.completedStoryPoints,
        reason: '${sprint.name} (id ${sprint.id}) biten SP',
      );
    }
  });

  test('tamamlanan sprintlerdeki görevlerin hepsi bitti', () {
    final completedIds = SampleData.sprints
        .where((s) => s.status == SprintStatus.completed)
        .map((s) => s.id)
        .toSet();
    final inCompleted = tasks.where((t) => completedIds.contains(t.sprintId));

    expect(inCompleted, isNotEmpty);
    expect(inCompleted.every((t) => t.status == TaskStatus.done), isTrue);
  });

  test('görev yalnızca kendi projesinin sprintinde', () {
    for (final task in tasks.where((t) => t.sprintId != null)) {
      final sprint = SampleData.sprints.firstWhere(
        (s) => s.id == task.sprintId,
      );
      expect(sprint.projectId, task.projectId, reason: task.title);
    }
  });

  test('her projede backlog görevi var', () {
    for (final project in SampleData.projects) {
      expect(
        tasks.where((t) => t.projectId == project.id && t.sprintId == null),
        isNotEmpty,
        reason: project.name,
      );
    }
  });

  test('her durum ve öncelikten görev var, bazıları atanmamış', () {
    expect(tasks.map((t) => t.status).toSet(), TaskStatus.values.toSet());
    expect(tasks.map((t) => t.priority).toSet(), TaskPriority.values.toSet());
    expect(tasks.where((t) => t.assignedUserId == null), isNotEmpty);
  });

  test('demo kullanıcısına en az 5 açık görev atanmış', () {
    final open = tasks.where(
      (t) =>
          t.assignedUserId == SampleData.demoUserId &&
          t.status != TaskStatus.done,
    );
    expect(open.length, greaterThanOrEqualTo(5));
  });
}
