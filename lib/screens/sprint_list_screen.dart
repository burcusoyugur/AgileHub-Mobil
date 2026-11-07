import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/sprint.dart';
import '../services/api_exception.dart';
import '../services/project_service.dart';
import '../services/sprint_service.dart';
import '../widgets/sprint_card.dart';
import '../widgets/state_views.dart';

/// Ekranda birlikte yüklenen veriler.
class _SprintListData {
  final List<Sprint> sprints;

  /// Proje adı yalnızca başlık için kullanılır; alınamazsa `null` kalır.
  final String? projectName;

  const _SprintListData(this.sprints, this.projectName);
}

class SprintListScreen extends StatefulWidget {
  final String projectId;

  const SprintListScreen({super.key, required this.projectId});

  @override
  State<SprintListScreen> createState() => _SprintListScreenState();
}

class _SprintListScreenState extends State<SprintListScreen> {
  late Future<_SprintListData> _future;

  /// Seçili durum filtresi; `null` = Tümü.
  SprintStatus? _filter;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(SprintListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // go_router aynı sayfayı başka projeyle yeniden kullanabiliyor.
    if (oldWidget.projectId != widget.projectId) {
      _filter = null;
      _future = _load();
    }
  }

  Future<_SprintListData> _load() async {
    final id = int.tryParse(widget.projectId);
    if (id == null) {
      throw const ApiException('Proje bulunamadı', statusCode: 404);
    }

    final projectService = context.read<ProjectService>();
    final sprintService = context.read<SprintService>();

    // Proje adı sadece başlıkta görünür; alınamasa da liste açılsın.
    final projectName = projectService
        .getProject(id)
        .then<String?>((project) => project.name)
        .catchError((_) => null);

    final sprints = await sprintService.getSprints(id);
    return _SprintListData(sprints, await projectName);
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

  void _openSprint(Sprint sprint) {
    switch (sprint.status) {
      case SprintStatus.active:
      case SprintStatus.planned:
        context.go('/projects/${widget.projectId}/board', extra: sprint.id);
      case SprintStatus.completed:
        context.go('/projects/${widget.projectId}/sprint-summary');
      case SprintStatus.cancelled:
        // İptal edilen sprintin gösterilecek panosu ya da özeti yok.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SprintListData>(
      future: _future,
      builder: (context, snapshot) {
        final projectName = snapshot.data?.projectName;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sprintler'),
                if (projectName != null)
                  Text(
                    projectName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            leading: BackButton(
              onPressed: () => context.go('/projects/${widget.projectId}'),
            ),
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_SprintListData> snapshot) {
    // Yenilerken eski veri ekranda kalsın, sadece ilk yüklemede bekleme göster.
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return ErrorView(
        message: error is ApiException
            ? error.message
            : 'Sprintler yüklenemedi',
        onRetry: _reload,
      );
    }

    final sprints = snapshot.data!.sprints;
    if (sprints.isEmpty) {
      return _scrollable(
        const EmptyView(
          icon: Icons.event_note_outlined,
          message: 'Bu projede henüz sprint yok',
        ),
      );
    }

    final visible = _filter == null
        ? sprints
        : sprints.where((s) => s.status == _filter).toList();

    return Column(
      children: [
        _FilterBar(
          sprints: sprints,
          selected: _filter,
          onSelected: (status) => setState(() => _filter = status),
        ),
        Expanded(
          child: visible.isEmpty
              ? _scrollable(
                  const EmptyView(
                    icon: Icons.filter_list_off,
                    message: 'Bu durumda sprint yok',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    // Liste ekranı doldurmasa da aşağı çekerek yenilenebilsin.
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final sprint = visible[index];
                      return SprintCard(
                        sprint: sprint,
                        onTap: sprint.status == SprintStatus.cancelled
                            ? null
                            : () => _openSprint(sprint),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  /// Boş durum görünümünü de aşağı çekerek yenilenebilir yapar.
  Widget _scrollable(Widget child) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Üstteki durum filtresi: Tümü + her sprint durumu ve sayısı.
class _FilterBar extends StatelessWidget {
  final List<Sprint> sprints;
  final SprintStatus? selected;
  final ValueChanged<SprintStatus?> onSelected;

  const _FilterBar({
    required this.sprints,
    required this.selected,
    required this.onSelected,
  });

  /// Chip sırası: Tümü, Aktif, Planlanıyor, Tamamlandı, İptal Edildi.
  static const _order = [
    SprintStatus.active,
    SprintStatus.planned,
    SprintStatus.completed,
    SprintStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    int count(SprintStatus status) =>
        sprints.where((s) => s.status == status).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text('Tümü (${sprints.length})'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final status in _order) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('${status.label} (${count(status)})'),
              selected: selected == status,
              onSelected: (_) => onSelected(status),
            ),
          ],
        ],
      ),
    );
  }
}
