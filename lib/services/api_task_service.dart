import '../models/task.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'task_service.dart';

/// [TaskService]'in ortak API ile çalışan gerçek uygulaması.
///
/// Uçlar: `GET /api/sprintler/{id}/gorevler`,
/// `GET /api/projeler/{projeId}/gorevler?sadeceBacklog=`,
/// `GET /api/gorevler/{id}`.
class ApiTaskService implements TaskService {
  final ApiClient _client;

  const ApiTaskService(this._client);

  @override
  Future<List<Task>> getSprintTasks(int sprintId) async {
    final List<dynamic> json;
    try {
      json = await _client.get(
        '/api/sprintler/$sprintId/gorevler',
      ) as List<dynamic>;
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const ApiException('Sprint bulunamadı', statusCode: 404);
      }
      rethrow;
    }
    return _parse(json);
  }

  @override
  Future<List<Task>> getProjectTasks(
    int projectId, {
    bool backlogOnly = false,
  }) async {
    final path = backlogOnly
        ? '/api/projeler/$projectId/gorevler?sadeceBacklog=true'
        : '/api/projeler/$projectId/gorevler';
    final List<dynamic> json;
    try {
      json = await _client.get(path) as List<dynamic>;
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const ApiException('Proje bulunamadı', statusCode: 404);
      }
      rethrow;
    }
    return _parse(json);
  }

  @override
  Future<Task> getTask(int id) async {
    try {
      final json = await _client.get('/api/gorevler/$id');
      return Task.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      // Sahte servisle aynı metin görünsün diye.
      if (e.isNotFound) {
        throw const ApiException('Görev bulunamadı', statusCode: 404);
      }
      rethrow;
    }
  }

  List<Task> _parse(List<dynamic> json) =>
      json.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
}
