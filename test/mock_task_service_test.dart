import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/data/sample_data.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/mock_task_service.dart';

Matcher _apiException(String message, int statusCode) => isA<ApiException>()
    .having((e) => e.message, 'message', message)
    .having((e) => e.statusCode, 'statusCode', statusCode);

void main() {
  const service = MockTaskService(delay: Duration.zero);

  group('MockTaskService', () {
    test('sprintin görevlerini döner', () async {
      // Proje 1'in aktif sprinti.
      final result = await service.getSprintTasks(3);

      expect(result, isNotEmpty);
      expect(result.every((t) => t.sprintId == 3), isTrue);
      expect(
        result.length,
        SampleData.tasks.where((t) => t.sprintId == 3).length,
      );
    });

    test('olmayan sprint için "Sprint bulunamadı" fırlatır', () async {
      await expectLater(
        service.getSprintTasks(999),
        throwsA(_apiException('Sprint bulunamadı', 404)),
      );
    });

    test('proje görevlerini döner, hepsi o projeye ait olur', () async {
      final result = await service.getProjectTasks(1);

      expect(result, isNotEmpty);
      expect(result.every((t) => t.projectId == 1), isTrue);
    });

    test('backlogOnly yalnızca sprinte atanmamış görevleri döner', () async {
      final result = await service.getProjectTasks(1, backlogOnly: true);

      expect(result, isNotEmpty);
      expect(
        result.every((t) => t.projectId == 1 && t.sprintId == null),
        isTrue,
      );
    });

    test('olmayan proje için "Proje bulunamadı" fırlatır', () async {
      await expectLater(
        service.getProjectTasks(999),
        throwsA(_apiException('Proje bulunamadı', 404)),
      );
    });

    test('tek görevi getirir', () async {
      final ilk = SampleData.tasks.first;

      final task = await service.getTask(ilk.id);

      expect(task.id, ilk.id);
      expect(task.title, ilk.title);
    });

    test('olmayan görev için "Görev bulunamadı" fırlatır', () async {
      await expectLater(
        service.getTask(999999),
        throwsA(_apiException('Görev bulunamadı', 404)),
      );
    });
  });
}
