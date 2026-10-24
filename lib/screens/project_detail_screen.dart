import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/sprint.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  static final List<Sprint> _sampleSprints = [
    Sprint(
      id: 1,
      projectId: 1,
      name: 'Sprint 1',
      startDate: DateTime(2026, 10, 21),
      endDate: DateTime(2026, 10, 25),
      isActive: true,
      totalStoryPoints: 20,
      completedStoryPoints: 5,
    ),
    Sprint(
      id: 2,
      projectId: 1,
      name: 'Sprint 2',
      startDate: DateTime(2026, 10, 26),
      endDate: DateTime(2026, 11, 1),
      isActive: false,
      totalStoryPoints: 0,
      completedStoryPoints: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proje #$projectId'),
        leading: BackButton(onPressed: () => context.go('/projects')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sprintler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ..._sampleSprints.map((sprint) => _SprintCard(
                sprint: sprint,
                onTap: () => context.go(
                  '/projects/$projectId/board',
                  extra: sprint.id,
                ),
              )),
        ],
      ),
    );
  }
}

class _SprintCard extends StatelessWidget {
  final Sprint sprint;
  final VoidCallback onTap;

  const _SprintCard({required this.sprint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = sprint.totalStoryPoints > 0
        ? sprint.completedStoryPoints / sprint.totalStoryPoints
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sprint.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (sprint.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${sprint.completedStoryPoints} / ${sprint.totalStoryPoints} SP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
