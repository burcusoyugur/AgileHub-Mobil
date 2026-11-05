import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/data/sample_data.dart';
import 'package:agilehub_mobil/models/sprint.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/mock_project_service.dart';
import 'package:agilehub_mobil/services/mock_sprint_service.dart';

void main() {
  const projects = MockProjectService(delay: Duration.zero);
  const sprints = MockSprintService(delay: Duration.zero);

  group('MockProjectService', () {
    test('projeleri en yeni oluşturulan önce döner', () async {
      final result = await projects.getProjects();

      expect(result, hasLength(SampleData.projects.length));
      for (var i = 1; i < result.length; i++) {
        expect(result[i - 1].createdAt.isAfter(result[i].createdAt), isTrue);
      }
    });

    test('olmayan proje için 404 fırlatır', () async {
      await expectLater(
        projects.getProject(999),
        throwsA(
          isA<ApiException>().having((e) => e.isNotFound, 'isNotFound', true),
        ),
      );
    });
  });

  group('MockSprintService', () {
    test(
      'yalnızca istenen projenin sprintlerini yeniden eskiye döner',
      () async {
        final result = await sprints.getSprints(1);

        expect(result, isNotEmpty);
        expect(result.every((s) => s.projectId == 1), isTrue);
        for (var i = 1; i < result.length; i++) {
          expect(result[i - 1].startDate.isAfter(result[i].startDate), isTrue);
        }
      },
    );

    test('sprinti olmayan proje için boş liste döner', () async {
      expect(await sprints.getSprints(3), isEmpty);
    });

    test('olmayan proje için 404 fırlatır', () async {
      await expectLater(sprints.getSprints(999), throwsA(isA<ApiException>()));
    });

    test('örnek veride her projede en fazla bir aktif sprint var', () {
      for (final project in SampleData.projects) {
        final active = SampleData.sprints.where(
          (s) => s.projectId == project.id && s.isActive,
        );
        expect(active.length, lessThanOrEqualTo(1), reason: project.name);
      }
    });
  });

  test('Sprint JSON dönüşümü API alan adlarını korur', () {
    final sprint = SampleData.sprints.firstWhere((s) => s.isActive);
    final copy = Sprint.fromJson(sprint.toJson());

    expect(copy.id, sprint.id);
    expect(copy.status, SprintStatus.active);
    expect(sprint.toJson()['durum'], 'Aktif');
    expect(copy.completedStoryPoints, sprint.completedStoryPoints);
  });
}
