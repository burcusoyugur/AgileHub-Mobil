import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/models/task.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/task_service.dart';
import 'package:agilehub_mobil/widgets/task_status_sheet.dart';

Task _gorev(TaskStatus durum, {String baslik = 'Giriş ekranı'}) => Task(
  id: 7,
  projectId: 1,
  sprintId: 3,
  title: baslik,
  status: durum,
  priority: TaskPriority.medium,
  createdAt: DateTime(2026, 11, 5),
);

class _SheetSonucu {
  TaskStatus? deger;
  bool kapandi = false;
}

/// Pencereyi açan bir düğme gösterir, ona basar; pencerenin sonucunu
/// dönen nesneye yazar.
Future<_SheetSonucu> _acSheet(WidgetTester tester, Task gorev) async {
  final sonuc = _SheetSonucu();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              sonuc.deger = await showTaskStatusSheet(context, gorev);
              sonuc.kapandi = true;
            },
            child: const Text('Aç'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Aç'));
  await tester.pumpAndSettle();
  return sonuc;
}

/// [updateStatus] cevabını testin kendisi verir (Completer ile).
class _FakeTaskService implements TaskService {
  final cagrilar = <TaskStatus>[];
  final cevap = Completer<Task>();

  @override
  Future<Task> updateStatus(int taskId, TaskStatus status) {
    cagrilar.add(status);
    return cevap.future;
  }

  @override
  Future<List<Task>> getSprintTasks(int sprintId) => throw UnimplementedError();

  @override
  Future<List<Task>> getProjectTasks(
    int projectId, {
    bool backlogOnly = false,
  }) => throw UnimplementedError();

  @override
  Future<Task> getTask(int id) => throw UnimplementedError();
}

/// Panoyu taklit eder: görevin durumunu yazar; "Aç" düğmesi (kart) yalnızca
/// görev "Yapılacak"tayken görünür, yani durum değişince kart ekrandan kalkar.
class _Pano extends StatefulWidget {
  final TaskService servis;

  const _Pano(this.servis);

  @override
  State<_Pano> createState() => _PanoState();
}

class _PanoState extends State<_Pano> {
  Task gorev = _gorev(TaskStatus.todo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Durum: ${gorev.status.label}'),
          if (gorev.status == TaskStatus.todo)
            Builder(
              builder: (context) => TextButton(
                onPressed: () => changeTaskStatus(
                  context,
                  task: gorev,
                  service: widget.servis,
                  onChanged: (t) => setState(() => gorev = t),
                ),
                child: const Text('Aç'),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  group('showTaskStatusSheet', () {
    testWidgets('4 durumu gösterir, mevcut durum işaretli', (tester) async {
      await _acSheet(tester, _gorev(TaskStatus.inProgress));

      expect(find.text('Durumu değiştir'), findsOneWidget);
      expect(find.text('Giriş ekranı'), findsOneWidget);
      for (final durum in TaskStatus.values) {
        expect(find.text(durum.label), findsOneWidget);
      }
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Yapılıyor'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('başka duruma dokununca onu döndürür', (tester) async {
      final sonuc = await _acSheet(tester, _gorev(TaskStatus.todo));

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(sonuc.kapandi, isTrue);
      expect(sonuc.deger, TaskStatus.testing);
      expect(find.text('Durumu değiştir'), findsNothing);
    });

    testWidgets('mevcut duruma dokununca null döner', (tester) async {
      final sonuc = await _acSheet(tester, _gorev(TaskStatus.todo));

      await tester.tap(find.text('Yapılacak'));
      await tester.pumpAndSettle();

      expect(sonuc.kapandi, isTrue);
      expect(sonuc.deger, isNull);
    });

    testWidgets('dışarı dokunup kapatınca null döner', (tester) async {
      final sonuc = await _acSheet(tester, _gorev(TaskStatus.todo));

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(sonuc.kapandi, isTrue);
      expect(sonuc.deger, isNull);
    });

    testWidgets('360 px genişlikte uzun başlıkla taşmaz', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _acSheet(
        tester,
        _gorev(TaskStatus.todo, baslik: 'Çok uzun bir görev başlığı ' * 8),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Bitti'), findsOneWidget);
    });
  });

  group('changeTaskStatus', () {
    testWidgets('iyimser günceller, başarıda bildirim gösterir', (
      tester,
    ) async {
      final servis = _FakeTaskService();
      await tester.pumpWidget(MaterialApp(home: _Pano(servis)));

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Sunucu henüz cevap vermedi ama görev yeni durumda görünüyor.
      expect(servis.cagrilar, [TaskStatus.testing]);
      expect(find.text('Durum: Test'), findsOneWidget);

      servis.cevap.complete(_gorev(TaskStatus.testing));
      await tester.pumpAndSettle();

      expect(find.text('Durum: Test'), findsOneWidget);
      expect(find.text("Görev 'Test' sütununa taşındı"), findsOneWidget);
    });

    testWidgets('hata olursa eski duruma döner ve hatayı gösterir', (
      tester,
    ) async {
      final servis = _FakeTaskService();
      await tester.pumpWidget(MaterialApp(home: _Pano(servis)));

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitti'));
      await tester.pumpAndSettle();
      expect(find.text('Durum: Bitti'), findsOneWidget);

      // Kart (düğme) bu sırada ekrandan kalktı; hata yine de gösterilmeli.
      servis.cevap.completeError(const ApiException('Sunucuya ulaşılamadı'));
      await tester.pumpAndSettle();

      expect(find.text('Durum: Yapılacak'), findsOneWidget);
      expect(find.text('Sunucuya ulaşılamadı'), findsOneWidget);
    });

    testWidgets('pencere kapatılırsa servis çağrılmaz', (tester) async {
      final servis = _FakeTaskService();
      await tester.pumpWidget(MaterialApp(home: _Pano(servis)));

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(servis.cagrilar, isEmpty);
      expect(find.text('Durum: Yapılacak'), findsOneWidget);
    });
  });
}
