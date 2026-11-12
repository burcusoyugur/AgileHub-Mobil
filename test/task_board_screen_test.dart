import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:agilehub_mobil/models/task.dart';
import 'package:agilehub_mobil/screens/task_board_screen.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/mock_sprint_service.dart';
import 'package:agilehub_mobil/services/sprint_service.dart';
import 'package:agilehub_mobil/services/task_service.dart';

Task _gorev(
  int id,
  String baslik,
  TaskStatus durum, {
  int? sprintId = 3,
  TaskPriority oncelik = TaskPriority.medium,
}) => Task(
  id: id,
  projectId: 1,
  sprintId: sprintId,
  title: baslik,
  status: durum,
  priority: oncelik,
  storyPoints: 3,
  createdAt: DateTime(2026, 11, 5),
);

/// Ekran testleri örnek verideki görev listesinden bağımsız kalsın diye
/// kendi listesiyle çalışan görev servisi.
class _FakeTaskService implements TaskService {
  final List<Task> tasks;
  int sprintCalls = 0;

  /// Doluysa her çağrıda bu hata fırlatılır.
  ApiException? error;

  _FakeTaskService(this.tasks);

  @override
  Future<List<Task>> getSprintTasks(int sprintId) async {
    sprintCalls++;
    if (error != null) throw error!;
    return tasks.where((t) => t.sprintId == sprintId).toList();
  }

  @override
  Future<List<Task>> getProjectTasks(
    int projectId, {
    bool backlogOnly = false,
  }) => throw UnimplementedError();

  @override
  Future<Task> getTask(int id) => throw UnimplementedError();
}

final _gorevler = [
  _gorev(1, 'Giriş ekranı', TaskStatus.todo),
  _gorev(2, 'Tema renkleri', TaskStatus.inProgress, oncelik: TaskPriority.high),
  _gorev(3, 'Model testleri', TaskStatus.inProgress),
  _gorev(4, 'Router', TaskStatus.testing),
  _gorev(5, 'İskelet', TaskStatus.done),
  // Başka sprinte ait; panoda görünmemeli.
  _gorev(6, 'Eski sprint görevi', TaskStatus.done, sprintId: 2),
  // Backlog görevi; panoda görünmemeli.
  _gorev(7, 'Backlog görevi', TaskStatus.todo, sprintId: null),
];

void _set360(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpBoard(
  WidgetTester tester, {
  required String projectId,
  int? sprintId,
  _FakeTaskService? taskService,
  Duration sprintDelay = Duration.zero,
  bool settle = true,
}) async {
  _set360(tester);

  final router = GoRouter(
    initialLocation: '/projects/$projectId/board',
    initialExtra: sprintId,
    routes: [
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) => const Text('Proje detay ekranı'),
        routes: [
          GoRoute(
            path: 'board',
            builder: (context, state) =>
                TaskBoardScreen(projectId: state.pathParameters['projectId']!),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<SprintService>.value(
          value: MockSprintService(delay: sprintDelay),
        ),
        Provider<TaskService>.value(
          value: taskService ?? _FakeTaskService(_gorevler),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final tab = find.widgetWithText(Tab, label);
  // Sekmeler yatay kaydırılıyor; sondakiler ekran dışında kalabilir.
  await tester.ensureVisible(tab);
  await tester.pumpAndSettle();
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sprintId verilmezse projenin aktif sprintinin görevleri '
      'doğru sekmelerde görünür', (tester) async {
    await _pumpBoard(tester, projectId: '1');

    // Aktif sprint 3: 1 yapılacak, 2 yapılıyor, 1 test, 1 bitti.
    expect(find.text('Yapılacak (1)'), findsOneWidget);
    expect(find.text('Yapılıyor (2)'), findsOneWidget);
    expect(find.text('Test (1)'), findsOneWidget);
    expect(find.text('Bitti (1)'), findsOneWidget);

    expect(find.text('Giriş ekranı'), findsOneWidget);
    expect(find.text('Backlog görevi'), findsNothing);

    await _openTab(tester, 'Yapılıyor (2)');
    expect(find.text('Tema renkleri'), findsOneWidget);
    expect(find.text('Model testleri'), findsOneWidget);
    expect(find.text('Giriş ekranı'), findsNothing);

    await _openTab(tester, 'Test (1)');
    expect(find.text('Router'), findsOneWidget);

    await _openTab(tester, 'Bitti (1)');
    expect(find.text('İskelet'), findsOneWidget);
    expect(find.text('Eski sprint görevi'), findsNothing);
  });

  testWidgets('extra ile gelen sprintId aktif sprintin önüne geçer', (
    tester,
  ) async {
    // Sprint 2 (tamamlanmış) panoda açılır.
    await _pumpBoard(tester, projectId: '1', sprintId: 2);

    expect(find.text('Bitti (1)'), findsOneWidget);
    expect(find.text('Yapılacak (0)'), findsOneWidget);

    await _openTab(tester, 'Bitti (1)');
    expect(find.text('Eski sprint görevi'), findsOneWidget);
    expect(find.text('İskelet'), findsNothing);
  });

  testWidgets('aktif sprint yoksa boş durum gösterilir', (tester) async {
    final servis = _FakeTaskService(_gorevler);
    // Proje 3'ün hiç sprinti yok.
    await _pumpBoard(tester, projectId: '3', taskService: servis);

    expect(find.text('Bu projede aktif sprint yok'), findsOneWidget);
    expect(find.text('Yapılacak (0)'), findsOneWidget);
    expect(servis.sprintCalls, 0);
  });

  testWidgets('hata olursa ErrorView ve Tekrar dene ile yeniden yüklenir', (
    tester,
  ) async {
    final servis = _FakeTaskService(_gorevler)
      ..error = const ApiException('Sunucuya ulaşılamadı');
    await _pumpBoard(tester, projectId: '1', taskService: servis);

    expect(find.text('Sunucuya ulaşılamadı'), findsOneWidget);
    expect(find.text('Giriş ekranı'), findsNothing);

    servis.error = null;
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.text('Sunucuya ulaşılamadı'), findsNothing);
    expect(find.text('Giriş ekranı'), findsOneWidget);
    expect(servis.sprintCalls, 2);
  });

  testWidgets('yüklenirken bekleme göstergesi çıkar', (tester) async {
    await _pumpBoard(
      tester,
      projectId: '1',
      sprintDelay: const Duration(seconds: 1),
      settle: false,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Giriş ekranı'), findsOneWidget);
  });

  testWidgets('aşağı çekince görevler yeniden yüklenir', (tester) async {
    final servis = _FakeTaskService(_gorevler);
    await _pumpBoard(tester, projectId: '1', taskService: servis);
    expect(servis.sprintCalls, 1);

    await tester.fling(find.text('Giriş ekranı'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(servis.sprintCalls, 2);
    expect(find.text('Giriş ekranı'), findsOneWidget);
  });
}
