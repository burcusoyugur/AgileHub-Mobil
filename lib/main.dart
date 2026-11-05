import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
import 'services/mock_project_service.dart';
import 'services/mock_sprint_service.dart';
import 'services/project_service.dart';
import 'services/sprint_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AgileHubApp());
}

class AgileHubApp extends StatefulWidget {
  const AgileHubApp({super.key});

  @override
  State<AgileHubApp> createState() => _AgileHubAppState();
}

class _AgileHubAppState extends State<AgileHubApp> {
  // Router her build'de yeniden oluşmasın diye state içinde tutulur.
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider()..tryAutoLogin();
    _router = createRouter(_auth);
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        // API 4. haftada hazır olana kadar ekranlar örnek veriyle çalışır.
        Provider<ProjectService>(create: (_) => const MockProjectService()),
        Provider<SprintService>(create: (_) => const MockSprintService()),
      ],
      child: MaterialApp.router(
        title: 'AgileHub Mobil',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
