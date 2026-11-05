import '../data/sample_data.dart';
import '../models/sprint.dart';
import 'api_exception.dart';
import 'sprint_service.dart';

/// [SampleData] ile çalışan SAHTE sprint servisi.
class MockSprintService implements SprintService {
  final Duration delay;

  const MockSprintService({this.delay = const Duration(milliseconds: 500)});

  @override
  Future<List<Sprint>> getSprints(int projectId) async {
    await Future.delayed(delay);
    // API'de olmayan projenin sprintleri istenirse 404 döner.
    if (!SampleData.projects.any((p) => p.id == projectId)) {
      throw const ApiException('Proje bulunamadı', statusCode: 404);
    }
    return SampleData.sprints.where((s) => s.projectId == projectId).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  @override
  Future<Sprint> getSprint(int id) async {
    await Future.delayed(delay);
    for (final sprint in SampleData.sprints) {
      if (sprint.id == id) return sprint;
    }
    throw const ApiException('Sprint bulunamadı', statusCode: 404);
  }
}
