import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/project_service.dart';
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

  @override
  void initState() {
    super.initState();
    _future = _load();
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        // Liste kısa ya da boş olsa da aşağı çekerek yenilenebilsin.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (projects.isEmpty)
            const EmptyView(
              icon: Icons.folder_off_outlined,
              message: 'Henüz üyesi olduğun bir proje yok',
            )
          else
            for (final project in projects) ...[
              _ProjectCard(project: project),
              const SizedBox(height: 12),
            ],
        ],
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
        subtitle: project.description != null
            ? Text(project.description!)
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/projects/${project.id}'),
      ),
    );
  }
}
