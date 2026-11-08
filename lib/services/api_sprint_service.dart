import '../models/sprint.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'sprint_service.dart';

/// [SprintService]'in ortak API ile çalışan gerçek uygulaması.
///
/// Uçlar: `GET /api/projeler/{projeId}/sprintler`, `GET /api/sprintler/{id}`.
class ApiSprintService implements SprintService {
  final ApiClient _client;

  const ApiSprintService(this._client);

  @override
  Future<List<Sprint>> getSprints(int projectId) async {
    final List<dynamic> json;
    try {
      json =
          await _client.get('/api/projeler/$projectId/sprintler')
              as List<dynamic>;
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const ApiException('Proje bulunamadı', statusCode: 404);
      }
      rethrow;
    }
    return json
        .map((e) => Sprint.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  @override
  Future<Sprint> getSprint(int id) async {
    try {
      final json = await _client.get('/api/sprintler/$id');
      return Sprint.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      // Sahte servisle aynı metin görünsün diye.
      if (e.isNotFound) {
        throw const ApiException('Sprint bulunamadı', statusCode: 404);
      }
      rethrow;
    }
  }
}
