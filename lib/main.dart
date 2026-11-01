import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
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
    return ChangeNotifierProvider.value(
      value: _auth,
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
