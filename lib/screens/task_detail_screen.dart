import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskDetailScreen extends StatelessWidget {
  final String projectId;
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev #$taskId'),
        leading: BackButton(
          onPressed: () => context.go('/projects/$projectId/board'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.go('/projects/$projectId/task/$taskId/edit'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Görev Detayı – 6. haftada geliştirilecek'),
      ),
    );
  }
}
