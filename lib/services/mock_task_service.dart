import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import 'api_exception.dart';
import 'task_service.dart';

/// [SampleData] ile çalışan SAHTE görev servisi.
class MockTaskService implements TaskService {
  final Duration delay;

  const MockTaskService({this.delay = const Duration(milliseconds: 500)});

  /// Sahte modda değiştirilen durumlar (görev id → yeni durum).
  ///
  /// Sınıf `const` olduğu için değişiklik nesnede değil sınıf düzeyinde
  /// tutulur; uygulama açık kaldıkça pano yenilense de yeni durum korunur.
  /// [SampleData] hiç değişmez.
  static final Map<int, TaskStatus> _statusOverrides = {};

  /// Testler birbirini etkilemesin diye değişiklikleri siler.
  @visibleForTesting
  static void resetStatusOverrides() => _statusOverrides.clear();

  /// Görev için yapılmış bir durum değişikliği varsa onu uygular.
  Task _withOverride(Task task) {
    final status = _statusOverrides[task.id];
    return status == null ? task : task.copyWith(status: status);
  }

  @override
  Future<List<Task>> getSprintTasks(int sprintId) async {
    await Future.delayed(delay);
    // API'de olmayan sprintin görevleri istenirse 404 döner.
    if (!SampleData.sprints.any((s) => s.id == sprintId)) {
      throw const ApiException('Sprint bulunamadı', statusCode: 404);
    }
    return SampleData.tasks
        .where((t) => t.sprintId == sprintId)
        .map(_withOverride)
        .toList();
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
        .map(_withOverride)
        .toList();
  }

  @override
  Future<Task> getTask(int id) async {
    await Future.delayed(delay);
    for (final task in SampleData.tasks) {
      if (task.id == id) return _withOverride(task);
    }
    throw const ApiException('Görev bulunamadı', statusCode: 404);
  }

  @override
  Future<Task> updateStatus(int taskId, TaskStatus status) async {
    await Future.delayed(delay);
    for (final task in SampleData.tasks) {
      if (task.id == taskId) {
        _statusOverrides[taskId] = status;
        return task.copyWith(status: status);
      }
    }
    throw const ApiException('Görev bulunamadı', statusCode: 404);
  }
}
