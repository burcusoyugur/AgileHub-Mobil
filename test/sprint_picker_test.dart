import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/models/sprint.dart';
import 'package:agilehub_mobil/widgets/sprint_picker.dart';
import 'package:agilehub_mobil/widgets/sprint_status_chip.dart';

Sprint _sprint(int id, SprintStatus durum, DateTime baslangic, {String? ad}) =>
    Sprint(
      id: id,
      projectId: 1,
      name: ad ?? 'Sprint $id',
      startDate: baslangic,
      endDate: baslangic.add(const Duration(days: 13)),
      status: durum,
      totalStoryPoints: 0,
      completedStoryPoints: 0,
    );

/// Örnek veriye benzer karışık sırada bir sprint listesi.
final _karisik = [
  _sprint(1, SprintStatus.completed, DateTime(2026, 10, 5)),
  _sprint(5, SprintStatus.planned, DateTime(2026, 12, 21)),
  _sprint(6, SprintStatus.cancelled, DateTime(2026, 11, 2)),
  _sprint(2, SprintStatus.completed, DateTime(2026, 10, 19)),
  _sprint(4, SprintStatus.planned, DateTime(2026, 12, 7)),
  _sprint(3, SprintStatus.active, DateTime(2026, 11, 23)),
];

/// Alttan açılan liste ekran yüksekliğiyle sınırlı; testte tüm satırlar
/// oluşturulsun diye görünümü uzatır.
void _tumListeSigsin(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('defaultSprintId', () {
    test('aktif sprint varsa onu seçer', () {
      expect(defaultSprintId(_karisik), 3);
    });

    test('aktif yoksa başlangıcı en yakın planlanan sprinti seçer', () {
      final sprints = _karisik.where((s) => !s.isActive).toList();
      expect(defaultSprintId(sprints), 4);
    });

    test('planlanan da yoksa en son biten tamamlanmış sprinti seçer', () {
      final sprints = _karisik
          .where(
            (s) =>
                s.status == SprintStatus.completed ||
                s.status == SprintStatus.cancelled,
          )
          .toList();
      expect(defaultSprintId(sprints), 2);
    });

    test('hiç sprint yoksa null döner', () {
      expect(defaultSprintId(const []), isNull);
    });

    test('yalnızca iptal edilen sprint varsa null döner', () {
      expect(
        defaultSprintId([
          _sprint(6, SprintStatus.cancelled, DateTime(2026, 11, 2)),
        ]),
        isNull,
      );
    });
  });

  group('sortSprintsForPicker', () {
    test('aktif, planlanan, tamamlanan, iptal sırasıyla dizer', () {
      final ids = sortSprintsForPicker(_karisik).map((s) => s.id).toList();
      expect(ids, [3, 4, 5, 2, 1, 6]);
    });

    test('gelen listeyi değiştirmez', () {
      final once = _karisik.map((s) => s.id).toList();
      sortSprintsForPicker(_karisik);
      expect(_karisik.map((s) => s.id).toList(), once);
    });
  });

  group('SprintPicker', () {
    Future<List<Sprint>> pumpPicker(
      WidgetTester tester, {
      List<Sprint>? sprints,
      int? selectedId = 3,
    }) async {
      final secilenler = <Sprint>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: SprintPicker(
                sprints: sprints ?? _karisik,
                selectedId: selectedId,
                onChanged: secilenler.add,
              ),
            ),
          ),
        ),
      );
      return secilenler;
    }

    testWidgets('seçili sprintin adını ve durumunu gösterir', (tester) async {
      await pumpPicker(tester);

      expect(find.text('Sprint 3'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('dokununca tüm sprintler sıralı listelenir', (tester) async {
      _tumListeSigsin(tester);
      await pumpPicker(tester);

      await tester.tap(find.byType(SprintPicker));
      await tester.pumpAndSettle();

      expect(find.text('Sprint seç'), findsOneWidget);
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.map((t) => (t.title as Text).data), [
        'Sprint 3',
        'Sprint 4',
        'Sprint 5',
        'Sprint 2',
        'Sprint 1',
        'Sprint 6',
      ]);
      // Yalnızca seçili sprint işaretli.
      expect(tiles.where((t) => t.selected).length, 1);
      expect(tiles.first.selected, isTrue);
      expect(find.text('23.11.2026 – 06.12.2026'), findsOneWidget);
    });

    testWidgets('iptal edilen sprint soluk görünür', (tester) async {
      _tumListeSigsin(tester);
      await pumpPicker(tester);

      await tester.tap(find.byType(SprintPicker));
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.widgetWithText(ListTile, 'Sprint 6'),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('başka sprint seçilince onChanged çağrılır', (tester) async {
      final secilenler = await pumpPicker(tester);

      await tester.tap(find.byType(SprintPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Sprint 2'));
      await tester.pumpAndSettle();

      expect(secilenler.map((s) => s.id), [2]);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('aynı sprint seçilince onChanged çağrılmaz', (tester) async {
      final secilenler = await pumpPicker(tester);

      await tester.tap(find.byType(SprintPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Sprint 3'));
      await tester.pumpAndSettle();

      expect(secilenler, isEmpty);
    });

    testWidgets('sprint yoksa "Sprint yok" yazar ve açılmaz', (tester) async {
      await pumpPicker(tester, sprints: const [], selectedId: null);

      expect(find.text('Sprint yok'), findsOneWidget);
      expect(find.byType(SprintStatusChip), findsNothing);

      await tester.tap(find.byType(SprintPicker));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('360 px genişlikte uzun adla taşmaz', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpPicker(
        tester,
        sprints: [
          _sprint(
            3,
            SprintStatus.active,
            DateTime(2026, 11, 23),
            ad: 'Kanban panosu ve görev durumlarının güncellenmesi sprinti',
          ),
        ],
      );

      expect(tester.takeException(), isNull);
    });
  });
}
