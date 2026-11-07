import '../models/sprint.dart';

/// Sprintleri getiren servis. Hata durumunda `ApiException` fırlatılır.
abstract class SprintService {
  /// Projenin tüm sprintleri, başlangıç tarihi en yeni olan önce.
  Future<List<Sprint>> getSprints(int projectId);

  /// Sprint yoksa ya da kullanıcı projenin üyesi değilse `ApiException`
  /// fırlatır.
  Future<Sprint> getSprint(int id);
}
