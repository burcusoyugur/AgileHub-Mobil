import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/data/sample_data.dart';
import 'package:agilehub_mobil/models/task.dart';
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

  group('MockTaskService.updateStatus', () {
    // Değişiklikler sınıf düzeyinde tutulduğu için her testten sonra silinir.
    tearDown(MockTaskService.resetStatusOverrides);

    test(
      'güncel görevi döner; sonraki okumalarda yeni durum görünür',
      () async {
        final gorev = SampleData.tasks.firstWhere(
          (t) => t.sprintId == 3 && t.status != TaskStatus.testing,
        );

        final guncel = await service.updateStatus(gorev.id, TaskStatus.testing);

        expect(guncel.id, gorev.id);
        expect(guncel.status, TaskStatus.testing);

        final sprint = await service.getSprintTasks(3);
        expect(
          sprint.firstWhere((t) => t.id == gorev.id).status,
          TaskStatus.testing,
        );
        expect((await service.getTask(gorev.id)).status, TaskStatus.testing);
        final proje = await service.getProjectTasks(gorev.projectId);
        expect(
          proje.firstWhere((t) => t.id == gorev.id).status,
          TaskStatus.testing,
        );
      },
    );

    test('örnek veriyi değiştirmez, diğer görevler etkilenmez', () async {
      final gorevler = SampleData.tasks.where((t) => t.sprintId == 3).toList();
      final ilk = gorevler[0];
      final ikinci = gorevler[1];
      final yeni = ilk.status == TaskStatus.done
          ? TaskStatus.todo
          : TaskStatus.done;

      await service.updateStatus(ilk.id, yeni);

      expect(
        SampleData.tasks.firstWhere((t) => t.id == ilk.id).status,
        ilk.status,
      );
      expect((await service.getTask(ikinci.id)).status, ikinci.status);
    });

    test('olmayan görev için "Görev bulunamadı" fırlatır', () async {
      await expectLater(
        service.updateStatus(999999, TaskStatus.done),
        throwsA(_apiException('Görev bulunamadı', 404)),
      );
    });
  });
}
