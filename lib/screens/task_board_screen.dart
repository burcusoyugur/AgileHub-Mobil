import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskBoardScreen extends StatelessWidget {
  final String projectId;

  const TaskBoardScreen({super.key, required this.projectId});

  static final List<Task> _sampleTasks = [
    Task(
      id: 1,
      sprintId: 1,
      title: 'Flutter proje iskeleti oluştur',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      storyPoints: 3,
      assignedUserName: 'Gözde Sarı',
      createdAt: DateTime(2026, 10, 21),
    ),
    Task(
      id: 2,
      sprintId: 1,
      title: 'Tema ve renk sistemi',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      storyPoints: 2,
      assignedUserName: 'Burcu Soyuğur',
      createdAt: DateTime(2026, 10, 21),
    ),
    Task(
      id: 3,
      sprintId: 1,
      title: 'Model sınıfları',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      storyPoints: 3,
      assignedUserName: 'Esra Topaktaş',
      createdAt: DateTime(2026, 10, 21),
    ),
    Task(
      id: 4,
      sprintId: 1,
      title: 'Sayfa yönlendirmesi (Router)',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      storyPoints: 2,
      assignedUserName: 'Erkim Ünsal',
      createdAt: DateTime(2026, 10, 21),
    ),
    Task(
      id: 5,
      sprintId: 1,
      title: 'Giriş ekranı UI',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      storyPoints: 3,
      createdAt: DateTime(2026, 10, 22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Görev Panosu'),
          leading: BackButton(
              onPressed: () => context.go('/projects/$projectId')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: TaskStatus.values.map((s) {
              final count =
                  _sampleTasks.where((t) => t.status == s).length;
              return Tab(text: '${s.label} ($count)');
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: TaskStatus.values.map((status) {
            final tasks =
                _sampleTasks.where((t) => t.status == status).toList();
            return _TaskList(tasks: tasks, projectId: projectId);
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/projects/$projectId/task/new'),
          child: const Icon(Icons.add),
        ),
      ),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Görev yok',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _priorityColor(task.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Row(
              children: [
                if (task.assignedUserName != null) ...[
                  Icon(Icons.person_outline,
                      size: 14,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(task.assignedUserName!,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                ],
                Chip(
                  label: Text('${task.storyPoints} SP'),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            onTap: () =>
                context.go('/projects/$projectId/task/${task.id}'),
          ),
        );
      },
    );
  }
}
