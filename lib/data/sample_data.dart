import '../models/project.dart';
import '../models/sprint.dart';
import '../models/task.dart';

/// Sahte modda (`USE_MOCK_DATA=true`) kullanılan örnek veri. Web'deki demo
/// verisiyle aynı projeler, sprintler ve görevler.
///
/// Ekranlar bu sınıfı doğrudan kullanmaz; sahte servisler buradan okur.
/// Böylece gerçek API'ye geçerken ekranlarda değişiklik gerekmez.
class SampleData {
  SampleData._();

  static const String demoUserId = 'demo-kullanici';

  /// Bugünden [days] gün önce ya da sonra (saatsiz). Web'deki demo verisi gibi
  /// tarihler bugüne göre hesaplanır: aktif sprintler her gün devam ediyor
  /// görünür, "x gün kaldı" anlamlı olur.
  static DateTime _day(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + days);
  }

  // Görevlerin atandığı kişiler. Web'deki demo kullanıcılarıyla aynı adlar.
  static const _demo = (id: demoUserId, name: 'Demo Kullanıcı');
  static const _gozde = (id: 'gozde', name: 'Gözde Sarı');
  static const _burcu = (id: 'burcu', name: 'Burcu Soyuğur');
  static const _esra = (id: 'esra', name: 'Esra Meriç Topaktaş');
  static const _erkim = (id: 'erkim', name: 'Erkim Berk Ünsal');

  /// Web'deki demo verisinde olduğu gibi projeleri yönetici oluşturur; sahte
  /// modda yönetici, giriş yapan demo kullanıcısıdır.
  static final List<Project> projects = [
    Project(
      id: 1,
      name: 'AgileHub Mobil',
      description: 'Çevik proje takip uygulamasının Flutter istemcisi',
      createdAt: _day(-35),
      createdByUserId: demoUserId,
      createdByUserName: 'Demo Kullanıcı',
    ),
    Project(
      id: 2,
      name: 'AgileHub Web',
      description: 'ASP.NET Core ile proje yönetim portalı ve ortak Web API',
      createdAt: _day(-37),
      createdByUserId: demoUserId,
      createdByUserName: 'Demo Kullanıcı',
    ),
    // Sprinti olmayan proje: boş durum ekranlarını denemek için.
    Project(
      id: 3,
      name: 'Kütüphane Otomasyonu',
      description: 'Ödünç alma ve iade takibi için örnek proje',
      createdAt: _day(-12),
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
      startDate: _day(-33),
      endDate: _day(-20),
      status: SprintStatus.completed,
      totalStoryPoints: 13,
      completedStoryPoints: 13,
    ),
    Sprint(
      id: 2,
      projectId: 1,
      name: 'Sprint 2',
      goal: 'Giriş, kayıt ve oturum yönetimi',
      startDate: _day(-19),
      endDate: _day(-6),
      status: SprintStatus.completed,
      totalStoryPoints: 18,
      completedStoryPoints: 18,
    ),
    Sprint(
      id: 3,
      projectId: 1,
      name: 'Sprint 3',
      goal: 'Proje ekranları ve servis katmanı',
      startDate: _day(-5),
      endDate: _day(9),
      status: SprintStatus.active,
      totalStoryPoints: 21,
      completedStoryPoints: 8,
    ),
    Sprint(
      id: 4,
      projectId: 1,
      name: 'Sprint 4',
      goal: 'Ekranların gerçek API\'ye bağlanması',
      startDate: _day(10),
      endDate: _day(23),
      status: SprintStatus.planned,
      totalStoryPoints: 13,
      completedStoryPoints: 0,
    ),
    Sprint(
      id: 5,
      projectId: 2,
      name: 'Sprint 1',
      goal: 'Veritabanı, kimlik doğrulama ve projeler',
      startDate: _day(-33),
      endDate: _day(-20),
      status: SprintStatus.completed,
      totalStoryPoints: 20,
      completedStoryPoints: 20,
    ),
    Sprint(
      id: 6,
      projectId: 2,
      name: 'Sprint 2',
      goal: 'Backlog ve sprintler',
      startDate: _day(-5),
      endDate: _day(9),
      status: SprintStatus.active,
      totalStoryPoints: 26,
      completedStoryPoints: 11,
    ),
    Sprint(
      id: 7,
      projectId: 2,
      name: 'Raporlama denemesi',
      startDate: _day(-19),
      endDate: _day(-15),
      status: SprintStatus.cancelled,
      totalStoryPoints: 5,
      completedStoryPoints: 0,
    ),
  ];

  /// Sprint görevleri ve backlog (`sprintId: null`). Her sprintin story point
  /// toplamları yukarıdaki `totalStoryPoints` / `completedStoryPoints` ile
  /// aynıdır: tamamlanan sprintlerde hepsi `done`, aktif sprintlerde karışık.
  static final List<Task> tasks = [
    // AgileHub Mobil – Sprint 1 (tamamlandı, 13 SP)
    _task(
      id: 1,
      projectId: 1,
      sprintId: 1,
      title: 'Flutter proje iskeleti oluştur',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _gozde,
      createdAt: _day(-33),
    ),
    _task(
      id: 2,
      projectId: 1,
      sprintId: 1,
      title: 'Tema ve renk sistemi',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      storyPoints: 3,
      assignee: _burcu,
      createdAt: _day(-33),
    ),
    _task(
      id: 3,
      projectId: 1,
      sprintId: 1,
      title: 'Model sınıfları ve JSON eşlemesi',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _esra,
      createdAt: _day(-33),
    ),
    // AgileHub Mobil – Sprint 2 (tamamlandı, 18 SP)
    _task(
      id: 4,
      projectId: 1,
      sprintId: 2,
      title: 'Giriş ekranında form doğrulaması',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _esra,
      createdAt: _day(-19),
    ),
    _task(
      id: 5,
      projectId: 1,
      sprintId: 2,
      title: 'Kayıt ekranı ve şifre kuralları',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      storyPoints: 5,
      assignee: _gozde,
      createdAt: _day(-19),
    ),
    _task(
      id: 6,
      projectId: 1,
      sprintId: 2,
      title: 'JWT ile giriş ve oturumun saklanması',
      status: TaskStatus.done,
      priority: TaskPriority.critical,
      storyPoints: 8,
      assignee: _burcu,
      createdAt: _day(-19),
    ),
    // AgileHub Mobil – Sprint 3 (aktif, 8 / 21 SP)
    _task(
      id: 7,
      projectId: 1,
      sprintId: 3,
      title: 'Projelerim ekranında arama',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      storyPoints: 5,
      assignee: _esra,
      createdAt: _day(-5),
    ),
    _task(
      id: 8,
      projectId: 1,
      sprintId: 3,
      title: 'Yükleniyor, hata ve boş durum bileşenleri',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      storyPoints: 3,
      assignee: _erkim,
      createdAt: _day(-5),
    ),
    _task(
      id: 9,
      projectId: 1,
      sprintId: 3,
      title: 'Sprint listesinde durum filtresi',
      status: TaskStatus.testing,
      priority: TaskPriority.medium,
      storyPoints: 5,
      assignee: _gozde,
      createdAt: _day(-5),
    ),
    _task(
      id: 10,
      projectId: 1,
      sprintId: 3,
      title: 'Proje detayında aktif sprint kartı',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _demo,
      createdAt: _day(-5),
    ),
    _task(
      id: 11,
      projectId: 1,
      sprintId: 3,
      title: 'API servis katmanı ve hata eşlemesi',
      status: TaskStatus.todo,
      priority: TaskPriority.critical,
      storyPoints: 3,
      assignee: _demo,
      createdAt: _day(-5),
    ),
    // AgileHub Mobil – Sprint 4 (planlanıyor, 13 SP)
    _task(
      id: 12,
      projectId: 1,
      sprintId: 4,
      title: "Görev Panosu'nu API'ye bağla",
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _gozde,
      createdAt: _day(-3),
    ),
    _task(
      id: 13,
      projectId: 1,
      sprintId: 4,
      title: 'Oturum düşünce giriş ekranına dön',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      storyPoints: 5,
      assignee: _burcu,
      createdAt: _day(-3),
    ),
    _task(
      id: 14,
      projectId: 1,
      sprintId: 4,
      title: 'Örnek veriyi web demo verisiyle eşitle',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      storyPoints: 3,
      assignee: _demo,
      createdAt: _day(-3),
    ),
    // AgileHub Mobil – backlog
    _task(
      id: 15,
      projectId: 1,
      sprintId: null,
      title: 'Görev durumunu sürükle-bırak ile değiştir',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      storyPoints: 8,
      assignee: null,
      createdAt: _day(-10),
    ),
    _task(
      id: 16,
      projectId: 1,
      sprintId: null,
      title: 'Sprint burndown grafiği',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      storyPoints: 5,
      assignee: _demo,
      createdAt: _day(-10),
    ),
    // AgileHub Web – Sprint 1 (tamamlandı, 20 SP)
    _task(
      id: 17,
      projectId: 2,
      sprintId: 5,
      title: 'Veritabanı şeması ve migration',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      storyPoints: 8,
      assignee: _erkim,
      createdAt: _day(-33),
    ),
    _task(
      id: 18,
      projectId: 2,
      sprintId: 5,
      title: 'ASP.NET Identity ile kimlik doğrulama',
      status: TaskStatus.done,
      priority: TaskPriority.critical,
      storyPoints: 8,
      assignee: _burcu,
      createdAt: _day(-33),
    ),
    _task(
      id: 19,
      projectId: 2,
      sprintId: 5,
      title: 'Proje oluşturma ve üye ekleme',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      storyPoints: 4,
      assignee: _esra,
      createdAt: _day(-33),
    ),
    // AgileHub Web – Sprint 2 (aktif, 11 / 26 SP)
    _task(
      id: 20,
      projectId: 2,
      sprintId: 6,
      title: 'Backlog listesi ve görev ekleme',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      storyPoints: 8,
      assignee: _gozde,
      createdAt: _day(-5),
    ),
    _task(
      id: 21,
      projectId: 2,
      sprintId: 6,
      title: 'Sprint oluşturma formu',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      storyPoints: 3,
      assignee: _erkim,
      createdAt: _day(-5),
    ),
    _task(
      id: 22,
      projectId: 2,
      sprintId: 6,
      title: 'Görevi sprinte atama',
      status: TaskStatus.testing,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _demo,
      createdAt: _day(-5),
    ),
    _task(
      id: 23,
      projectId: 2,
      sprintId: 6,
      title: 'Sprint detayında story point ilerlemesi',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      storyPoints: 5,
      assignee: _esra,
      createdAt: _day(-5),
    ),
    _task(
      id: 24,
      projectId: 2,
      sprintId: 6,
      title: 'Projeler ve Sprintler API uçları',
      status: TaskStatus.todo,
      priority: TaskPriority.critical,
      storyPoints: 5,
      assignee: _erkim,
      createdAt: _day(-5),
    ),
    // AgileHub Web – "Raporlama denemesi" (iptal edildi, 5 SP)
    _task(
      id: 25,
      projectId: 2,
      sprintId: 7,
      title: 'Haftalık rapor PDF çıktısı',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      storyPoints: 5,
      assignee: null,
      createdAt: _day(-19),
    ),
    // AgileHub Web – backlog
    _task(
      id: 26,
      projectId: 2,
      sprintId: null,
      title: 'Görevlere etiket ekleme',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      storyPoints: 3,
      assignee: _burcu,
      createdAt: _day(-8),
    ),
    _task(
      id: 27,
      projectId: 2,
      sprintId: null,
      title: 'Bildirim e-postaları',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      storyPoints: 5,
      assignee: null,
      createdAt: _day(-8),
    ),
    // Kütüphane Otomasyonu – yalnızca backlog (sprint yok)
    _task(
      id: 28,
      projectId: 3,
      sprintId: null,
      title: 'Kitap ödünç alma kaydı',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      storyPoints: 5,
      assignee: _demo,
      createdAt: _day(-11),
    ),
    _task(
      id: 29,
      projectId: 3,
      sprintId: null,
      title: 'Geciken iadeler için uyarı',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      storyPoints: 3,
      assignee: null,
      createdAt: _day(-11),
    ),
  ];

  static Task _task({
    required int id,
    required int projectId,
    required int? sprintId,
    required String title,
    required TaskStatus status,
    required TaskPriority priority,
    required int storyPoints,
    required ({String id, String name})? assignee,
    required DateTime createdAt,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      sprintId: sprintId,
      title: title,
      status: status,
      priority: priority,
      storyPoints: storyPoints,
      assignedUserId: assignee?.id,
      assignedUserName: assignee?.name,
      createdAt: createdAt,
    );
  }
}
