import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../models/sprint.dart';
import '../services/api_exception.dart';
import '../services/project_service.dart';
import '../services/sprint_service.dart';
import '../utils/formatters.dart';
import '../widgets/sprint_status_chip.dart';
import '../widgets/state_views.dart';

/// Proje detay ekranında birlikte yüklenen veriler.
class _ProjectDetailData {
  final Project project;
  final List<Sprint> sprints;

  const _ProjectDetailData(this.project, this.sprints);

  /// Bir projede aynı anda en fazla bir aktif sprint olur.
  Sprint? get activeSprint {
    for (final sprint in sprints) {
      if (sprint.isActive) return sprint;
    }
    return null;
  }
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

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // Hata FutureBuilder üzerinden ekranda gösteriliyor.
    }
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        // Ekran dolmasa da aşağı çekerek yenilenebilsin.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ProjectHeader(project: data.project),
          const SizedBox(height: 12),
          _SprintStats(sprints: data.sprints),
          const SizedBox(height: 24),
          const _SectionTitle('Aktif Sprint'),
          const SizedBox(height: 12),
          if (data.activeSprint case final sprint?)
            _ActiveSprintCard(sprint: sprint, projectId: widget.projectId)
          else
            const _NoActiveSprintCard(),
          const SizedBox(height: 24),
          _RecentSprints(sprints: data.sprints, projectId: widget.projectId),
        ],
      ),
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

/// Sprint sayısı, tamamlanan sprintler ve bitirilen story point toplamı.
class _SprintStats extends StatelessWidget {
  final List<Sprint> sprints;

  const _SprintStats({required this.sprints});

  @override
  Widget build(BuildContext context) {
    final completed = sprints
        .where((s) => s.status == SprintStatus.completed)
        .length;
    final doneStoryPoints = sprints
        .where((s) => s.status != SprintStatus.cancelled)
        .fold<int>(0, (sum, s) => sum + s.completedStoryPoints);

    return Row(
      children: [
        Expanded(
          child: _StatTile(value: '${sprints.length}', label: 'Sprint'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(value: '$completed', label: 'Tamamlanan'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(value: '$doneStoryPoints', label: 'Biten SP'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ActiveSprintCard extends StatelessWidget {
  final Sprint sprint;
  final String projectId;

  const _ActiveSprintCard({required this.sprint, required this.projectId});

  /// Bitiş tarihine kalan gün; geçmişse negatif.
  int get _remainingDays {
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.dateOnly(sprint.endDate).difference(today).inDays;
  }

  String get _remainingLabel {
    final days = _remainingDays;
    if (days > 0) return '$days gün kaldı';
    if (days == 0) return 'Bugün bitiyor';
    return 'Süresi doldu';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = sprint.totalStoryPoints;
    final completed = sprint.completedStoryPoints;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      margin: EdgeInsets.zero,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SprintStatusChip(status: sprint.status),
              ],
            ),
            if (sprint.goal != null) ...[
              const SizedBox(height: 4),
              Text(
                sprint.goal!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    formatDateRange(sprint.startDate, sprint.endDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  _remainingLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _remainingDays < 0 ? colors.error : colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  formatStoryPoints(completed, total),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '%${(progress * 100).round()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => context.go(
                      '/projects/$projectId/board',
                      extra: sprint.id,
                    ),
                    icon: const Icon(Icons.view_kanban_outlined),
                    label: const Text('Görev Panosu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.go('/projects/$projectId/sprint-summary'),
                    icon: const Icon(Icons.insights_outlined),
                    label: const Text('Sprint Özeti'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveSprintCard extends StatelessWidget {
  const _NoActiveSprintCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Aktif sprint yok'),
        subtitle: Text(
          'Planlanan bir sprint web portalından başlatıldığında burada görünür.',
        ),
      ),
    );
  }
}

/// Aktif sprint dışındaki en yeni sprintler; tamamı Sprintler ekranında.
class _RecentSprints extends StatelessWidget {
  static const int _previewCount = 3;

  final List<Sprint> sprints;
  final String projectId;

  const _RecentSprints({required this.sprints, required this.projectId});

  @override
  Widget build(BuildContext context) {
    // Servis sprintleri yeniden eskiye sıralı döndürüyor.
    final preview = sprints
        .where((s) => !s.isActive)
        .take(_previewCount)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Sprintler')),
            if (sprints.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/projects/$projectId/sprints'),
                child: Text('Tümünü gör (${sprints.length})'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (sprints.isEmpty)
          const EmptyView(
            icon: Icons.event_note_outlined,
            message: 'Bu projede henüz sprint yok',
          )
        else if (preview.isEmpty)
          Text(
            'Aktif sprint dışında sprint yok',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...preview.map(
            (sprint) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  sprint.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${formatDateRange(sprint.startDate, sprint.endDate)}\n'
                  '${formatStoryPoints(sprint.completedStoryPoints, sprint.totalStoryPoints)}',
                ),
                isThreeLine: true,
                trailing: SprintStatusChip(status: sprint.status),
                onTap: () =>
                    context.go('/projects/$projectId/board', extra: sprint.id),
              ),
            ),
          ),
      ],
    );
  }
}
