import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
import 'services/api_client.dart';
import 'services/api_config.dart';
import 'services/api_project_service.dart';
import 'services/api_sprint_service.dart';
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
  late final ApiClient _apiClient;

  // Oturum düşünce hangi ekranda olunursa olsun bildirim gösterebilmek için.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider()..tryAutoLogin();
    _router = createRouter(_auth);
    _apiClient = ApiClient(
      tokenProvider: () => _auth.token,
      onUnauthorized: _onSessionExpired,
    );
  }

  /// API 401 döndürdüğünde (token'ın süresi dolmuş ya da geçersiz) çağrılır.
  /// Çıkış yapılır, router giriş ekranına yönlendirir ve bildirim gösterilir.
  void _onSessionExpired() {
    // Ekrandaki birkaç istek aynı anda 401 alabilir; bildirim bir kez gösterilir.
    if (!_auth.isLoggedIn) return;
    _auth.logout();
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Oturumun süresi doldu, lütfen tekrar giriş yap'),
        ),
      );
  }

  @override
  void dispose() {
    _router.dispose();
    _apiClient.close();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        // USE_MOCK_DATA açıkken (varsayılan) ekranlar örnek veriyle,
        // kapalıyken ortak API ile çalışır. Ekranlarda hiçbir şey değişmez.
        Provider<ProjectService>(
          create: (_) => ApiConfig.useMockData
              ? const MockProjectService()
              : ApiProjectService(_apiClient),
        ),
        Provider<SprintService>(
          create: (_) => ApiConfig.useMockData
              ? const MockSprintService()
              : ApiSprintService(_apiClient),
        ),
      ],
      child: MaterialApp.router(
        title: 'AgileHub Mobil',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        scaffoldMessengerKey: _messengerKey,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
