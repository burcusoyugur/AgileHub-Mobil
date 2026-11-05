import '../models/project.dart';

/// Projeleri getiren servis.
///
/// Ekranlar yalnızca bu arayüzü kullanır. Örnek veriyle mi yoksa gerçek
/// API ile mi çalışılacağı `main.dart`'ta seçilir. Hata durumunda
/// `ApiException` fırlatılır.
abstract class ProjectService {
  /// Kullanıcının üyesi olduğu projeler, en yeni oluşturulan önce.
  Future<List<Project>> getProjects();

  /// Proje yoksa ya da kullanıcı üyesi değilse `ApiException` fırlatır.
  Future<Project> getProject(int id);
}
