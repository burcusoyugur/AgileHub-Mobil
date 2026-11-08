import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/project_service.dart';
import '../utils/formatters.dart';
import '../widgets/state_views.dart';

/// Kullanıcının üyesi olduğu projeler. Veri [ProjectService] üzerinden gelir;
/// sahte ya da gerçek servis `main.dart`'ta seçilir.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late Future<List<Project>> _future;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Aramada büyük/küçük harf farkını kaldırır. Dart'ın `toLowerCase`'i
  /// Türkçe İ/I harflerini doğru çevirmediği için i, ı, İ ve I aynı sayılır.
  static String _normalize(String text) => text
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .toLowerCase()
      .replaceAll('ı', 'i')
      .trim();

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<List<Project>> _load() => context.read<ProjectService>().getProjects();

  // setState'e Future döndüren bir closure verilmemeli; atama süslü
  // parantez içinde yapılır.
  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      // Hata FutureBuilder üzerinden ekranda gösteriliyor.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projelerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            // Çıkıştan sonra router'daki redirect /login'e yönlendirir.
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<Project>>(
        future: _future,
        builder: (context, snapshot) => _buildBody(snapshot),
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Project>> snapshot) {
    // Yenilerken eski liste ekranda kalsın, sadece ilk yüklemede bekleme göster.
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return ErrorView(
        message: error is ApiException ? error.message : 'Projeler yüklenemedi',
        onRetry: _reload,
      );
    }

    final projects = snapshot.data!;
    final query = _normalize(_query);
    final filtered = query.isEmpty
        ? projects
        : projects.where((p) => _normalize(p.name).contains(query)).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        // Liste kısa ya da boş olsa da aşağı çekerek yenilenebilsin.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const _Greeting(),
          if (projects.isEmpty)
            const EmptyView(
              icon: Icons.folder_off_outlined,
              message: 'Henüz üyesi olduğun bir proje yok',
            )
          else ...[
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Proje ara',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Aramayı temizle',
                        onPressed: _clearSearch,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const EmptyView(
                icon: Icons.search_off,
                message: 'Aramanla eşleşen proje yok',
              )
            else
              for (final project in filtered) ...[
                _ProjectCard(project: project),
                const SizedBox(height: 12),
              ],
          ],
        ],
      ),
    );
  }
}

/// Giriş yapan kullanıcının adıyla karşılama; ad bilinmiyorsa hiç görünmez.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final firstName = context.select<AuthProvider, String?>(
      (auth) => auth.currentUser?.firstName,
    );
    if (firstName == null || firstName.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'Merhaba, $firstName',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Text(
            project.name.isEmpty ? '?' : project.name[0],
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description case final description?
                when description.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            _ProjectMeta(project: project),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/projects/${project.id}'),
      ),
    );
  }
}

/// Kartın alt satırı: oluşturan kişi ve oluşturma tarihi.
class _ProjectMeta extends StatelessWidget {
  final Project project;

  const _ProjectMeta({required this.project});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: color);

    return Row(
      children: [
        Icon(Icons.person_outline, size: 14, color: color),
        const SizedBox(width: 4),
        // Uzun adlar dar ekranda taşmasın, tarih her zaman görünsün.
        Flexible(
          child: Text(
            project.createdByUserName ?? 'Bilinmiyor',
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.calendar_today_outlined, size: 14, color: color),
        const SizedBox(width: 4),
        Text(formatDate(project.createdAt), style: style),
      ],
    );
  }
}
