import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:agilehub_mobil/data/sample_data.dart';
import 'package:agilehub_mobil/models/project.dart';
import 'package:agilehub_mobil/providers/auth_provider.dart';
import 'package:agilehub_mobil/screens/projects_screen.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/auth_service.dart';
import 'package:agilehub_mobil/services/mock_project_service.dart';
import 'package:agilehub_mobil/services/project_service.dart';

/// Hiç projesi olmayan kullanıcı.
class _EmptyProjectService implements ProjectService {
  @override
  Future<List<Project>> getProjects() async => [];

  @override
  Future<Project> getProject(int id) => throw UnimplementedError();
}

/// İlk istekte sunucuya ulaşılamıyor, sonrakilerde örnek veriyi döner.
class _FlakyProjectService implements ProjectService {
  int calls = 0;

  @override
  Future<List<Project>> getProjects() async {
    calls++;
    if (calls == 1) throw const ApiException('Sunucuya ulaşılamadı');
    return const MockProjectService(delay: Duration.zero).getProjects();
  }

  @override
  Future<Project> getProject(int id) => throw UnimplementedError();
}

/// Sabit bir proje listesi döner; kaç kez istendiğini sayar.
class _FixedProjectService implements ProjectService {
  final List<Project> projects;
  int calls = 0;

  _FixedProjectService(this.projects);

  @override
  Future<List<Project>> getProjects() async {
    calls++;
    return projects;
  }

  @override
  Future<Project> getProject(int id) => throw UnimplementedError();
}

Project _project(
  int id,
  String name, {
  String? description,
  String? createdByUserName,
}) {
  return Project(
    id: id,
    name: name,
    description: description,
    createdAt: DateTime(2026, 11, id),
    createdByUserId: 'kullanici-$id',
    createdByUserName: createdByUserName,
  );
}

/// Projelerim ekranını verilen servisle açar.
Future<void> _pumpProjects(
  WidgetTester tester, {
  ProjectService service = const MockProjectService(delay: Duration.zero),
}) async {
  final router = GoRouter(
    initialLocation: '/projects',
    routes: [
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) =>
            Text('Proje detayı ${state.pathParameters['projectId']}'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<ProjectService>.value(value: service),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('üç projeyi en yeni oluşturulan önce listeler', (tester) async {
    await _pumpProjects(tester);

    final newest = find.text('Kütüphane Otomasyonu');
    final middle = find.text('AgileHub Mobil');
    final oldest = find.text('AgileHub Web');
    expect(newest, findsOneWidget);
    expect(middle, findsOneWidget);
    expect(oldest, findsOneWidget);

    expect(
      tester.getTopLeft(newest).dy,
      lessThan(tester.getTopLeft(middle).dy),
    );
    expect(
      tester.getTopLeft(middle).dy,
      lessThan(tester.getTopLeft(oldest).dy),
    );
  });

  testWidgets('kartta oluşturan kişi ve tarih görünür', (tester) async {
    await _pumpProjects(tester);

    expect(find.text('Burcu Soyuğur'), findsOneWidget);
    expect(find.text('03.11.2026'), findsOneWidget);
  });

  testWidgets('projeye dokununca detay sayfasına gider', (tester) async {
    await _pumpProjects(tester);

    await tester.tap(find.text('AgileHub Web'));
    await tester.pumpAndSettle();

    expect(find.text('Proje detayı 2'), findsOneWidget);
  });

  testWidgets('ada göre arar, sonuç yoksa boş durum gösterir', (tester) async {
    await _pumpProjects(tester);

    await tester.enterText(find.byType(TextField), 'web');
    await tester.pump();
    expect(find.text('AgileHub Web'), findsOneWidget);
    expect(find.text('AgileHub Mobil'), findsNothing);

    // Büyük harfle yazılsa da bulunur.
    await tester.enterText(find.byType(TextField), 'OTOMASYON');
    await tester.pump();
    expect(find.text('Kütüphane Otomasyonu'), findsOneWidget);
    expect(find.text('AgileHub Web'), findsNothing);

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump();
    expect(find.text('Aramanla eşleşen proje yok'), findsOneWidget);
  });

  testWidgets('projesi olmayan kullanıcıda boş durum gösterir', (tester) async {
    await _pumpProjects(tester, service: _EmptyProjectService());

    expect(find.text('Henüz üyesi olduğun bir proje yok'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('hata gösterir, tekrar deneyince listeyi yükler', (tester) async {
    final service = _FlakyProjectService();
    await _pumpProjects(tester, service: service);

    expect(find.text('Sunucuya ulaşılamadı'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(service.calls, 2);
    expect(find.text('Kütüphane Otomasyonu'), findsOneWidget);
  });

  testWidgets('aşağı çekince projeleri yeniden yükler', (tester) async {
    final service = _FixedProjectService([_project(1, 'AgileHub Mobil')]);
    await _pumpProjects(tester, service: service);
    expect(service.calls, 1);

    await tester.fling(find.text('AgileHub Mobil'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(service.calls, 2);
    expect(find.text('AgileHub Mobil'), findsOneWidget);
  });

  testWidgets('temizle butonu aramayı sıfırlar', (tester) async {
    await _pumpProjects(tester);

    // Arama boşken temizle butonu görünmez.
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'web');
    await tester.pump();
    expect(find.text('AgileHub Mobil'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(find.byIcon(Icons.clear), findsNothing);
    expect(find.text('AgileHub Mobil'), findsOneWidget);
    expect(find.text('AgileHub Web'), findsOneWidget);
    expect(find.text('Kütüphane Otomasyonu'), findsOneWidget);
  });

  testWidgets('Türkçe harflerde büyük/küçük harf farkı gözetmez', (
    tester,
  ) async {
    final service = _FixedProjectService([
      _project(1, 'İş Takibi'),
      _project(2, 'Işık Sistemi'),
      _project(3, 'Çiçek Bahçesi'),
      _project(4, 'Kütüphane Otomasyonu'),
    ]);
    await _pumpProjects(tester, service: service);

    Future<void> search(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    // i, ı, İ ve I aynı sayıldığı için "iş" iki projeyle de eşleşir.
    await search('iş');
    expect(find.text('İş Takibi'), findsOneWidget);
    expect(find.text('Işık Sistemi'), findsOneWidget);
    expect(find.text('Çiçek Bahçesi'), findsNothing);

    await search('İŞ TAKİBİ');
    expect(find.text('İş Takibi'), findsOneWidget);
    expect(find.text('Işık Sistemi'), findsNothing);

    await search('IŞIK');
    expect(find.text('Işık Sistemi'), findsOneWidget);
    expect(find.text('İş Takibi'), findsNothing);

    await search('ışık');
    expect(find.text('Işık Sistemi'), findsOneWidget);

    await search('ÇİÇEK');
    expect(find.text('Çiçek Bahçesi'), findsOneWidget);
    expect(find.text('İş Takibi'), findsNothing);

    await search('kütüp');
    expect(find.text('Kütüphane Otomasyonu'), findsOneWidget);
    expect(find.text('Çiçek Bahçesi'), findsNothing);
  });

  testWidgets('giriş yapan kullanıcıyı adıyla karşılar', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    await _pumpProjects(tester);

    // Oturum yokken karşılama satırı görünmez.
    expect(find.textContaining('Merhaba'), findsNothing);

    final auth = tester
        .element(find.byType(ProjectsScreen))
        .read<AuthProvider>();
    final login = auth.login(AuthService.demoEmail, 'herhangi');
    // Sahte giriş servisi kısa bir süre bekliyor.
    await tester.pump(const Duration(seconds: 1));
    await login;
    await tester.pump();

    expect(find.text('Merhaba, Demo'), findsOneWidget);

    // Provider'ı kapatıp oturum süresi zamanlayıcısını iptal et.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('açıklama en fazla iki satır, boş açıklama gösterilmez', (
    tester,
  ) async {
    final longDescription = 'Çok uzun bir proje açıklaması ' * 20;
    final service = _FixedProjectService([
      _project(1, 'Uzun Açıklamalı', description: longDescription),
      _project(2, 'Boş Açıklamalı', description: '   '),
    ]);
    await _pumpProjects(tester, service: service);

    final description = tester.widget<Text>(find.text(longDescription));
    expect(description.maxLines, 2);
    expect(description.overflow, TextOverflow.ellipsis);

    expect(find.text('   '), findsNothing);
    // Oluşturan adı bilinmeyen projelerde yer tutucu gösterilir.
    expect(find.text('Bilinmiyor'), findsNWidgets(2));
  });

  testWidgets('360 dp genişlikte taşma olmaz', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final service = _FixedProjectService([
      _project(
        1,
        'Çok Uzun Adlı Bir Proje Adı ki Dar Ekrana Sığması Zor Olsun',
        description: 'Uzun bir açıklama ' * 10,
        createdByUserName:
            'Şahyan Burcu Soyuğur Uzunsoyadlıoğlu Bilmemneoğulları',
      ),
      ...SampleData.projects,
    ]);
    await _pumpProjects(tester, service: service);

    expect(tester.takeException(), isNull);
    expect(find.text('03.11.2026'), findsWidgets);

    // Arama ve boş arama durumu da sığmalı.
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
