import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:agilehub_mobil/screens/project_detail_screen.dart';
import 'package:agilehub_mobil/services/mock_project_service.dart';
import 'package:agilehub_mobil/services/mock_sprint_service.dart';
import 'package:agilehub_mobil/services/project_service.dart';
import 'package:agilehub_mobil/services/sprint_service.dart';

/// Proje detay ekranını örnek veriyle ve beklemesiz sahte servislerle açar.
Future<GoRouter> _pumpDetail(WidgetTester tester, String projectId) async {
  final router = GoRouter(
    initialLocation: '/projects/$projectId',
    routes: [
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/projects/:projectId/sprints',
        builder: (context, state) => const Text('Sprint listesi ekranı'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ProjectService>.value(
          value: const MockProjectService(delay: Duration.zero),
        ),
        Provider<SprintService>.value(
          value: const MockSprintService(delay: Duration.zero),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('proje bilgisini ve aktif sprinti gösterir', (tester) async {
    await _pumpDetail(tester, '1');

    expect(find.text('AgileHub Mobil'), findsWidgets);
    expect(find.text('Demo Kullanıcı'), findsOneWidget);
    expect(find.text('Sprint 3'), findsOneWidget);
    expect(find.text('8 / 21 SP'), findsOneWidget);
    expect(find.text('Görev Panosu'), findsOneWidget);
    expect(find.text('Sprint Özeti'), findsOneWidget);
  });

  testWidgets('sprinti olmayan projede boş durumları gösterir', (tester) async {
    await _pumpDetail(tester, '3');

    expect(find.text('Aktif sprint yok'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bu projede henüz sprint yok'),
      200,
    );
    expect(find.text('Bu projede henüz sprint yok'), findsOneWidget);
  });

  testWidgets('olmayan projede hata ve tekrar dene gösterir', (tester) async {
    await _pumpDetail(tester, '999');

    expect(find.text('Proje bulunamadı'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('adres başka projeye değişince onu yükler', (tester) async {
    final router = await _pumpDetail(tester, '1');

    router.go('/projects/2');
    // İlk kare yeni yüklemeyi başlatır, ardından sahte servisin beklemesi biter.
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('AgileHub Web'), findsWidgets);
    expect(find.text('AgileHub Mobil'), findsNothing);
  });

  testWidgets('"Tümünü gör" sprint listesine gider', (tester) async {
    await _pumpDetail(tester, '1');

    final allSprints = find.text('Tümünü gör (4)');
    await tester.scrollUntilVisible(allSprints, 200);
    await tester.ensureVisible(allSprints);
    await tester.pumpAndSettle();
    await tester.tap(allSprints);
    await tester.pumpAndSettle();

    expect(find.text('Sprint listesi ekranı'), findsOneWidget);
  });
}
