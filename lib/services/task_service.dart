import '../models/task.dart';

/// Görevleri getiren servis. Hata durumunda `ApiException` fırlatılır.
abstract class TaskService {
  /// Sprintteki görevler. Sprint yoksa ya da kullanıcı üye değilse
  /// `ApiException` fırlatır.
  Future<List<Task>> getSprintTasks(int sprintId);

  /// Projenin görevleri. [backlogOnly] true ise yalnızca sprinte atanmamış
  /// görevler gelir.
  Future<List<Task>> getProjectTasks(int projectId, {bool backlogOnly = false});

  /// Görev yoksa ya da kullanıcı projenin üyesi değilse `ApiException`
  /// fırlatır.
  Future<Task> getTask(int id);

  /// Görevin durumunu değiştirir ve güncel görevi döndürür.
  ///
  /// Görev yoksa (404), kullanıcı üye değilse (403) ya da durum geçersizse
  /// (400) `ApiException` fırlatır.
  Future<Task> updateStatus(int taskId, TaskStatus status);
}
