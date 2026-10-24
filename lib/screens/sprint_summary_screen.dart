import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SprintSummaryScreen extends StatelessWidget {
  final String projectId;

  const SprintSummaryScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint Özeti'),
        leading: BackButton(
          onPressed: () => context.go('/projects/$projectId'),
        ),
      ),
      body: const Center(
        child: Text('Sprint Özeti ve Burndown – 7. haftada geliştirilecek'),
      ),
    );
  }
}
