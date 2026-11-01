import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/project.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  static final List<Project> _sampleProjects = [
    Project(
      id: 1,
      name: 'AgileHub Mobil',
      description: 'Çevik proje takip mobil uygulaması',
      createdAt: DateTime(2026, 10, 1),
      createdByUserId: 'demo-kullanici',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projelerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleProjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final project = _sampleProjects[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  project.name[0],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                project.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: project.description != null
                  ? Text(project.description!)
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/projects/${project.id}'),
            ),
          );
        },
      ),
    );
  }
}
