import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../models/sprint.dart';
import '../services/api_exception.dart';
import '../services/project_service.dart';
import '../services/sprint_service.dart';
import '../utils/formatters.dart';
import '../widgets/state_views.dart';

/// Proje detay ekranında birlikte yüklenen veriler.
class _ProjectDetailData {
  final Project project;
  final List<Sprint> sprints;

  const _ProjectDetailData(this.project, this.sprints);
}

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Future<_ProjectDetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(ProjectDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // go_router aynı sayfayı başka projeyle yeniden kullanabiliyor.
    if (oldWidget.projectId != widget.projectId) {
      _future = _load();
    }
  }

  Future<_ProjectDetailData> _load() async {
    final id = int.tryParse(widget.projectId);
    if (id == null) {
      throw const ApiException('Proje bulunamadı', statusCode: 404);
    }

    // Proje ve sprintleri aynı anda iste, ikisini birlikte göster.
    final results = await Future.wait<Object>([
      context.read<ProjectService>().getProject(id),
      context.read<SprintService>().getSprints(id),
    ]);
    return _ProjectDetailData(
      results[0] as Project,
      results[1] as List<Sprint>,
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProjectDetailData>(
      future: _future,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(snapshot.data?.project.name ?? 'Proje'),
            leading: BackButton(onPressed: () => context.go('/projects')),
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_ProjectDetailData> snapshot) {
    // Yenilerken eski veri ekranda kalsın, sadece ilk yüklemede bekleme göster.
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return ErrorView(
        message: error is ApiException ? error.message : 'Proje yüklenemedi',
        onRetry: _reload,
      );
    }

    final data = snapshot.data!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProjectHeader(project: data.project),
        const SizedBox(height: 24),
        Text(
          'Sprintler',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...data.sprints.map(
          (sprint) => _SprintCard(
            sprint: sprint,
            onTap: () => context.go(
              '/projects/${widget.projectId}/board',
              extra: sprint.id,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final Project project;

  const _ProjectHeader({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    project.name[0],
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    project.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (project.description != null) ...[
              const SizedBox(height: 12),
              Text(project.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoItem(
                  icon: Icons.person_outline,
                  text: project.createdByUserName ?? 'Bilinmiyor',
                ),
                _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  text: formatDate(project.createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: color),
          ),
        ),
      ],
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
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
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
