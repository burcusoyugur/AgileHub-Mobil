import '../models/project.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'project_service.dart';

/// [ProjectService]'in ortak API ile çalışan gerçek uygulaması.
///
/// Uçlar: `GET /api/projeler`, `GET /api/projeler/{id}`.
class ApiProjectService implements ProjectService {
  final ApiClient _client;

  const ApiProjectService(this._client);

  @override
  Future<List<Project>> getProjects() async {
    final json = await _client.get('/api/projeler') as List<dynamic>;
    return json
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Project> getProject(int id) async {
    try {
      final json = await _client.get('/api/projeler/$id');
      return Project.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      // Sahte servisle aynı metin görünsün diye.
      if (e.isNotFound) {
        throw const ApiException('Proje bulunamadı', statusCode: 404);
      }
      rethrow;
    }
  }
}
