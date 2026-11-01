import 'package:flutter/material.dart';

/// Kayıtlı oturum kontrol edilirken gösterilen bekleme ekranı.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
