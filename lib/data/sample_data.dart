import '../models/project.dart';
import '../models/sprint.dart';

/// Ortak API 4. haftada hazır olana kadar kullanılan örnek veri.
///
/// Ekranlar bu sınıfı doğrudan kullanmaz; sahte servisler buradan okur.
/// Böylece gerçek API'ye geçerken ekranlarda değişiklik gerekmez.
class SampleData {
  SampleData._();

  static const String demoUserId = 'demo-kullanici';

  static final List<Project> projects = [
    Project(
      id: 1,
      name: 'AgileHub Mobil',
      description: 'Çevik proje takip uygulamasının Flutter istemcisi',
      createdAt: DateTime(2026, 10, 20),
      createdByUserId: demoUserId,
      createdByUserName: 'Demo Kullanıcı',
    ),
    Project(
      id: 2,
      name: 'AgileHub Web',
      description: 'ASP.NET Core ile proje yönetim portalı ve ortak Web API',
      createdAt: DateTime(2026, 10, 18),
      createdByUserId: 'burcu',
      createdByUserName: 'Burcu Soyuğur',
    ),
    // Sprinti olmayan proje: boş durum ekranlarını denemek için.
    Project(
      id: 3,
      name: 'Kütüphane Otomasyonu',
      description: 'Ödünç alma ve iade takibi için örnek proje',
      createdAt: DateTime(2026, 11, 3),
      createdByUserId: demoUserId,
      createdByUserName: 'Demo Kullanıcı',
    ),
  ];

  /// Her projede en fazla bir aktif sprint var (web'deki kural).
  static final List<Sprint> sprints = [
    Sprint(
      id: 1,
      projectId: 1,
      name: 'Sprint 1',
      goal: 'Proje iskeleti, tema ve yönlendirme',
      startDate: DateTime(2026, 10, 21),
      endDate: DateTime(2026, 10, 25),
      status: SprintStatus.completed,
      totalStoryPoints: 13,
      completedStoryPoints: 13,
    ),
    Sprint(
      id: 2,
      projectId: 1,
      name: 'Sprint 2',
      goal: 'Giriş, kayıt ve oturum yönetimi',
      startDate: DateTime(2026, 10, 26),
      endDate: DateTime(2026, 11, 1),
      status: SprintStatus.completed,
      totalStoryPoints: 18,
      completedStoryPoints: 18,
    ),
    Sprint(
      id: 3,
      projectId: 1,
      name: 'Sprint 3',
      goal: 'Proje ekranları ve servis katmanı',
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 8),
      status: SprintStatus.active,
      totalStoryPoints: 21,
      completedStoryPoints: 8,
    ),
    Sprint(
      id: 4,
      projectId: 1,
      name: 'Sprint 4',
      goal: 'Ekranların gerçek API\'ye bağlanması',
      startDate: DateTime(2026, 11, 16),
      endDate: DateTime(2026, 11, 22),
      status: SprintStatus.planned,
      totalStoryPoints: 13,
      completedStoryPoints: 0,
    ),
    Sprint(
      id: 5,
      projectId: 2,
      name: 'Sprint 1',
      goal: 'Veritabanı, kimlik doğrulama ve projeler',
      startDate: DateTime(2026, 10, 21),
      endDate: DateTime(2026, 11, 1),
      status: SprintStatus.completed,
      totalStoryPoints: 20,
      completedStoryPoints: 20,
    ),
    Sprint(
      id: 6,
      projectId: 2,
      name: 'Sprint 2',
      goal: 'Backlog ve sprintler',
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 8),
      status: SprintStatus.active,
      totalStoryPoints: 26,
      completedStoryPoints: 11,
    ),
    Sprint(
      id: 7,
      projectId: 2,
      name: 'Raporlama denemesi',
      startDate: DateTime(2026, 10, 28),
      endDate: DateTime(2026, 10, 31),
      status: SprintStatus.cancelled,
      totalStoryPoints: 5,
      completedStoryPoints: 0,
    ),
  ];
}
