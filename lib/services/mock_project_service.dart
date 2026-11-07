import '../data/sample_data.dart';
import '../models/project.dart';
import 'api_exception.dart';
import 'project_service.dart';

/// [SampleData] ile çalışan SAHTE proje servisi.
///
/// Gerçek bir sunucuya istek atıyormuş gibi [delay] kadar bekler. Testlerde
/// beklememek için `Duration.zero` verilebilir.
class MockProjectService implements ProjectService {
  final Duration delay;

  const MockProjectService({this.delay = const Duration(milliseconds: 500)});

  @override
  Future<List<Project>> getProjects() async {
    await Future.delayed(delay);
    return [...SampleData.projects]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Project> getProject(int id) async {
    await Future.delayed(delay);
    for (final project in SampleData.projects) {
      if (project.id == id) return project;
    }
    throw const ApiException('Proje bulunamadı', statusCode: 404);
  }
}
