import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:agilehub_mobil/screens/sprint_list_screen.dart';
import 'package:agilehub_mobil/services/mock_project_service.dart';
import 'package:agilehub_mobil/services/mock_sprint_service.dart';
import 'package:agilehub_mobil/services/project_service.dart';
import 'package:agilehub_mobil/services/sprint_service.dart';
import 'package:agilehub_mobil/widgets/sprint_card.dart';

/// Sprint listesini örnek veriyle ve beklemesiz sahte servislerle açar.
Future<void> _pumpList(WidgetTester tester, String projectId) async {
  final router = GoRouter(
    initialLocation: '/projects/$projectId/sprints',
    routes: [
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) => const Text('Proje detay ekranı'),
        routes: [
          GoRoute(
            path: 'sprints',
            builder: (context, state) =>
                SprintListScreen(projectId: state.pathParameters['projectId']!),
          ),
          GoRoute(
            path: 'board',
            builder: (context, state) => Text('Pano ekranı ${state.extra}'),
          ),
          GoRoute(
            path: 'sprint-summary',
            builder: (context, state) => const Text('Sprint özeti ekranı'),
          ),
        ],
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
}

Future<void> _selectFilter(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(ChoiceChip, label);
  // Çipler yatay kaydırılıyor; sondakiler ekran dışında kalabilir.
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

/// Listede aşağıda kalan karta kaydırıp dokunur.
Future<void> _tapSprint(WidgetTester tester, String name) async {
  final card = find.text(name);
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('proje 1: 4 sprint listelenir, en yeni başta', (tester) async {
    await _pumpList(tester, '1');

    expect(find.byType(SprintCard), findsNWidgets(4));
    expect(find.text('AgileHub Mobil'), findsOneWidget); // başlıktaki proje adı
    expect(find.text('Tümü (4)'), findsOneWidget);

    // Başlangıç tarihi en yeni olan Sprint 4, en eskisi Sprint 1.
    final first = tester.getTopLeft(find.text('Sprint 4'));
    final last = tester.getTopLeft(find.text('Sprint 1'));
    expect(first.dy, lessThan(last.dy));
  });

  testWidgets('proje 1: "Tamamlandı" filtresinde 2 sprint kalır', (
    tester,
  ) async {
    await _pumpList(tester, '1');

    await _selectFilter(tester, 'Tamamlandı (2)');

    expect(find.byType(SprintCard), findsNWidgets(2));
    expect(find.text('Sprint 1'), findsOneWidget);
    expect(find.text('Sprint 2'), findsOneWidget);
    expect(find.text('Sprint 3'), findsNothing);
  });

  testWidgets('proje 1: iptal edilen sprint yoksa "Bu durumda sprint yok"', (
    tester,
  ) async {
    await _pumpList(tester, '1');

    await _selectFilter(tester, 'İptal Edildi (0)');

    expect(find.byType(SprintCard), findsNothing);
    expect(find.text('Bu durumda sprint yok'), findsOneWidget);

    // "Tümü"ne dönünce liste geri gelir.
    await _selectFilter(tester, 'Tümü (4)');
    expect(find.byType(SprintCard), findsNWidgets(4));
  });

  testWidgets('proje 2: "İptal Edildi" filtresinde 1 sprint kalır', (
    tester,
  ) async {
    await _pumpList(tester, '2');

    await _selectFilter(tester, 'İptal Edildi (1)');

    expect(find.byType(SprintCard), findsOneWidget);
    expect(find.text('Raporlama denemesi'), findsOneWidget);
  });

  testWidgets('proje 3: hiç sprint yoksa boş durum gösterir', (tester) async {
    await _pumpList(tester, '3');

    expect(find.text('Bu projede henüz sprint yok'), findsOneWidget);
    expect(find.byType(SprintCard), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('olmayan projede hata ve tekrar dene gösterir', (tester) async {
    await _pumpList(tester, '999');

    expect(find.text('Proje bulunamadı'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('aktif sprint panoya gider', (tester) async {
    await _pumpList(tester, '1');

    await _tapSprint(tester, 'Sprint 3');
    expect(find.text('Pano ekranı 3'), findsOneWidget);
  });

  testWidgets('tamamlanan sprint sprint özetine gider', (tester) async {
    await _pumpList(tester, '1');

    await _tapSprint(tester, 'Sprint 1');
    expect(find.text('Sprint özeti ekranı'), findsOneWidget);
  });

  testWidgets('iptal edilen sprint dokununca bir yere gitmez', (tester) async {
    await _pumpList(tester, '2');

    await _tapSprint(tester, 'Raporlama denemesi');
    expect(find.byType(SprintCard), findsNWidgets(3));
  });

  testWidgets('geri butonu proje detayına döner', (tester) async {
    await _pumpList(tester, '1');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Proje detay ekranı'), findsOneWidget);
  });

  testWidgets('360 px genişlikte taşma olmaz', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpList(tester, '2');

    expect(tester.takeException(), isNull);
  });
}
