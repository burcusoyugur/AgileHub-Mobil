import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/models/task.dart';
import 'package:agilehub_mobil/theme/app_theme.dart';
import 'package:agilehub_mobil/widgets/task_card.dart';

Task _task({
  String title = 'Giriş ekranında şifre doğrulaması',
  TaskPriority priority = TaskPriority.high,
  int? storyPoints = 5,
  String? assignedUserName = 'Gözde Sarı',
}) {
  return Task(
    id: 1,
    projectId: 1,
    sprintId: 3,
    title: title,
    status: TaskStatus.todo,
    priority: priority,
    storyPoints: storyPoints,
    assignedUserId: assignedUserName == null ? null : 'gozde',
    assignedUserName: assignedUserName,
    createdAt: DateTime(2026, 11, 20),
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  TaskCard card, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: [card]),
      ),
    ),
  );
}

void main() {
  testWidgets('başlık, öncelik, story point ve atanan kişi görünür', (
    tester,
  ) async {
    await _pumpCard(tester, TaskCard(task: _task()));

    expect(find.text('Giriş ekranında şifre doğrulaması'), findsOneWidget);
    expect(find.text('Yüksek'), findsOneWidget);
    expect(find.text('5 SP'), findsOneWidget);
    expect(find.text('Gözde Sarı'), findsOneWidget);
    // Atanan kişinin baş harfi avatarda.
    expect(find.text('G'), findsOneWidget);
  });

  testWidgets('atanmamış görevde "Atanmamış", SP yoksa çip yok', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      TaskCard(task: _task(assignedUserName: null, storyPoints: null)),
    );

    expect(find.text('Atanmamış'), findsOneWidget);
    expect(find.textContaining('SP'), findsNothing);
  });

  testWidgets('Türkçe i ile başlayan adın baş harfi İ olur', (tester) async {
    await _pumpCard(
      tester,
      TaskCard(task: _task(assignedUserName: 'ilknur Demir')),
    );

    expect(find.text('İ'), findsOneWidget);
  });

  testWidgets('öncelik etiketleri ve şerit rengi temadan gelir', (
    tester,
  ) async {
    final colors = AppTheme.light.colorScheme;
    final expected = {
      TaskPriority.critical: ('Kritik', colors.error),
      TaskPriority.high: ('Yüksek', colors.secondary),
      TaskPriority.medium: ('Orta', colors.primary),
      TaskPriority.low: ('Düşük', colors.outline),
    };

    for (final entry in expected.entries) {
      await _pumpCard(tester, TaskCard(task: _task(priority: entry.key)));

      expect(find.text(entry.value.$1), findsOneWidget);
      final bar = tester.widget<Container>(
        find.byKey(const ValueKey('task-card-priority-bar')),
      );
      expect(bar.color, entry.value.$2, reason: entry.value.$1);
    }
  });

  testWidgets('karta dokununca onTap, düğmeye dokununca onStatusTap', (
    tester,
  ) async {
    var taps = 0;
    var statusTaps = 0;
    await _pumpCard(
      tester,
      TaskCard(
        task: _task(),
        onTap: () => taps++,
        onStatusTap: () => statusTaps++,
      ),
    );

    await tester.tap(find.text('Giriş ekranında şifre doğrulaması'));
    expect(taps, 1);
    expect(statusTaps, 0);

    await tester.tap(find.byTooltip('Durumu değiştir'));
    expect(statusTaps, 1);
    expect(taps, 1);
  });

  testWidgets('onStatusTap yoksa durum düğmesi görünmez', (tester) async {
    await _pumpCard(tester, TaskCard(task: _task(), onTap: () {}));

    expect(find.byTooltip('Durumu değiştir'), findsNothing);
    expect(find.byIcon(Icons.swap_horiz), findsNothing);
  });

  testWidgets('ekran okuyucu kartı tek cümle olarak okur', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpCard(tester, TaskCard(task: _task(), onTap: () {}));

    expect(
      find.bySemanticsLabel(
        'Giriş ekranında şifre doğrulaması, Yüksek öncelik, '
        '5 story point, Gözde Sarı',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('başlık en fazla iki satır, 360 dp genişlikte taşma olmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final longTitle = 'Çok uzun bir görev başlığı ' * 8;
    await _pumpCard(
      tester,
      TaskCard(
        task: _task(
          title: longTitle,
          priority: TaskPriority.critical,
          storyPoints: 13,
          assignedUserName: 'Şahyan Burcu Soyuğur Uzunsoyadlıoğlu',
        ),
        onTap: () {},
        onStatusTap: () {},
      ),
    );

    final title = tester.widget<Text>(find.text(longTitle));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('koyu temada da hatasız çizilir', (tester) async {
    await _pumpCard(
      tester,
      TaskCard(task: _task(), onStatusTap: () {}),
      theme: AppTheme.dark,
    );

    expect(tester.takeException(), isNull);
    final bar = tester.widget<Container>(
      find.byKey(const ValueKey('task-card-priority-bar')),
    );
    expect(bar.color, AppTheme.dark.colorScheme.secondary);
  });
}
