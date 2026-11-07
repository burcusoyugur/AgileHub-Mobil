import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SprintListScreen extends StatelessWidget {
  final String projectId;

  const SprintListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprintler'),
        leading: BackButton(
          onPressed: () => context.go('/projects/$projectId'),
        ),
      ),
      body: const Center(
        child: Text('Sprint listesi – 3. haftada geliştirilecek'),
      ),
    );
  }
}
