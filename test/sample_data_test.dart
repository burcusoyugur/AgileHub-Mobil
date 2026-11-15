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

  group('tarihler bugüne göre', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('aktif sprintler bugün devam ediyor', () {
      final active = SampleData.sprints.where((s) => s.isActive);
      expect(active, hasLength(2));
      for (final sprint in active) {
        expect(sprint.startDate.isAfter(today), isFalse, reason: sprint.name);
        expect(sprint.endDate.isBefore(today), isFalse, reason: sprint.name);
      }
    });

    test('tamamlanan ve iptal edilen sprintler geçmişte', () {
      final past = SampleData.sprints.where(
        (s) =>
            s.status == SprintStatus.completed ||
            s.status == SprintStatus.cancelled,
      );
      for (final sprint in past) {
        expect(sprint.endDate.isBefore(today), isTrue, reason: sprint.name);
      }
    });

    test('planlanan sprint gelecekte', () {
      final planned = SampleData.sprints.where(
        (s) => s.status == SprintStatus.planned,
      );
      expect(planned, isNotEmpty);
      for (final sprint in planned) {
        expect(sprint.startDate.isAfter(today), isTrue, reason: sprint.name);
      }
    });

    test('sprint ve görevler projeden sonra oluşturulmuş', () {
      for (final project in SampleData.projects) {
        final created = project.createdAt;
        for (final s in SampleData.sprints.where(
          (s) => s.projectId == project.id,
        )) {
          expect(s.startDate.isBefore(created), isFalse, reason: s.name);
        }
        for (final t in tasks.where((t) => t.projectId == project.id)) {
          expect(t.createdAt.isBefore(created), isFalse, reason: t.title);
        }
      }
    });
  });
}
