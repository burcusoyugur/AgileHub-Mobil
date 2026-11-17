import '../data/sample_data.dart';
import '../models/task.dart';
import 'api_exception.dart';
import 'task_service.dart';

/// [SampleData] ile çalışan SAHTE görev servisi.
class MockTaskService implements TaskService {
  final Duration delay;

  const MockTaskService({this.delay = const Duration(milliseconds: 500)});

  @override
  Future<List<Task>> getSprintTasks(int sprintId) async {
    await Future.delayed(delay);
    // API'de olmayan sprintin görevleri istenirse 404 döner.
    if (!SampleData.sprints.any((s) => s.id == sprintId)) {
      throw const ApiException('Sprint bulunamadı', statusCode: 404);
    }
    return SampleData.tasks.where((t) => t.sprintId == sprintId).toList();
  }

  @override
  Future<List<Task>> getProjectTasks(
    int projectId, {
    bool backlogOnly = false,
  }) async {
    await Future.delayed(delay);
    if (!SampleData.projects.any((p) => p.id == projectId)) {
      throw const ApiException('Proje bulunamadı', statusCode: 404);
    }
    return SampleData.tasks
        .where(
          (t) =>
              t.projectId == projectId && (!backlogOnly || t.sprintId == null),
        )
        .toList();
  }

  @override
  Future<Task> getTask(int id) async {
    await Future.delayed(delay);
    for (final task in SampleData.tasks) {
      if (task.id == id) return task;
    }
    throw const ApiException('Görev bulunamadı', statusCode: 404);
  }
}
