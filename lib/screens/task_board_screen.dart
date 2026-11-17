import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/api_exception.dart';
import '../services/sprint_service.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

/// Panoda gösterilecek veriler: hangi sprint ve onun görevleri.
class _BoardData {
  /// Aktif sprint yoksa `null`; pano boş durum gösterir.
  final int? sprintId;
  final List<Task> tasks;

  const _BoardData(this.sprintId, this.tasks);
}

class TaskBoardScreen extends StatefulWidget {
  final String projectId;

  const TaskBoardScreen({super.key, required this.projectId});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  Future<_BoardData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Yönlendirmeden gelen `extra` (sprintId) burada okunabilir, initState'te değil.
    _future ??= _load();
  }

  @override
  void didUpdateWidget(TaskBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // go_router aynı sayfayı başka projeyle yeniden kullanabiliyor.
    if (oldWidget.projectId != widget.projectId) {
      _future = _load();
    }
  }

  Future<_BoardData> _load() async {
    final projectId = int.tryParse(widget.projectId);
    if (projectId == null) {
      throw const ApiException('Proje bulunamadı', statusCode: 404);
    }

    final extra = GoRouterState.of(context).extra;
    final taskService = context.read<TaskService>();
    final sprintService = context.read<SprintService>();

    var sprintId = extra is int ? extra : null;
    if (sprintId == null) {
      // Sprint verilmediyse projenin aktif sprintini bul.
      final sprints = await sprintService.getSprints(projectId);
      for (final sprint in sprints) {
        if (sprint.isActive) {
          sprintId = sprint.id;
          break;
        }
      }
    }
    if (sprintId == null) return const _BoardData(null, []);

    return _BoardData(sprintId, await taskService.getSprintTasks(sprintId));
  }

  void _reload() {
    final future = _load();
    setState(() {
      _future = future;
    });
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      // Hata FutureBuilder üzerinden ekranda gösteriliyor.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BoardData>(
      future: _future,
      builder: (context, snapshot) {
        final tasks = snapshot.data?.tasks ?? const <Task>[];
        return DefaultTabController(
          length: TaskStatus.values.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Görev Panosu'),
              leading: BackButton(
                onPressed: () => context.go('/projects/${widget.projectId}'),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: TaskStatus.values.map((s) {
                  final count = tasks.where((t) => t.status == s).length;
                  return Tab(text: '${s.label} ($count)');
                }).toList(),
              ),
            ),
            body: _buildBody(snapshot),
            floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  context.go('/projects/${widget.projectId}/task/new'),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_BoardData> snapshot) {
    // Yenilerken eski veri ekranda kalsın, sadece ilk yüklemede bekleme göster.
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return ErrorView(
        message: error is ApiException ? error.message : 'Görevler yüklenemedi',
        onRetry: _reload,
      );
    }

    final data = snapshot.data!;
    if (data.sprintId == null) {
      return const EmptyView(message: 'Bu projede aktif sprint yok');
    }

    return TabBarView(
      children: TaskStatus.values.map((status) {
        final tasks = data.tasks.where((t) => t.status == status).toList();
        return RefreshIndicator(
          onRefresh: _refresh,
          child: _TaskList(tasks: tasks, projectId: widget.projectId),
        );
      }).toList(),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final String projectId;

  const _TaskList({required this.tasks, required this.projectId});

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.critical:
        return AppTheme.inProgressColor;
      case TaskPriority.high:
        return AppTheme.testingColor;
      case TaskPriority.medium:
        return AppTheme.doneColor;
      case TaskPriority.low:
        return AppTheme.todoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      // Aşağı çekip yenileme boş sekmede de çalışsın diye kaydırılabilir.
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const EmptyView(message: 'Görev yok'),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _priorityColor(task.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Row(
              children: [
                if (task.assignedUserName != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedUserName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                ],
                if (task.storyPoints != null)
                  Chip(
                    label: Text('${task.storyPoints} SP'),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            onTap: () => context.go('/projects/$projectId/task/${task.id}'),
          ),
        );
      },
    );
  }
}
