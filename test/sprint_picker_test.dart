import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/models/sprint.dart';
import 'package:agilehub_mobil/widgets/sprint_picker.dart';

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
}
