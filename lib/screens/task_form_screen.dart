import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskFormScreen extends StatelessWidget {
  final String projectId;
  final String? taskId;

  const TaskFormScreen({
    super.key,
    required this.projectId,
    this.taskId,
  });

  bool get isEditing => taskId != null && taskId != 'new';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Görevi Düzenle' : 'Görev Ekle'),
        leading: BackButton(
          onPressed: () => context.go('/projects/$projectId/board'),
        ),
      ),
      body: const Center(
        child: Text('Görev Formu – 6. haftada geliştirilecek'),
      ),
    );
  }
}
