import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

/// Uygulamanın oturum durumunu tutar. Ekranlar ve router bunu dinler.
///
/// Giriş/kayıt hataları [AuthException] olarak ekrana kadar iletilir.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthProvider({AuthService? authService, TokenStorage? tokenStorage})
    : _authService = authService ?? AuthService(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  User? _currentUser;
  String? _token;
  DateTime? _expiresAt;
  bool _isInitializing = true;
  Timer? _expiryTimer;

  User? get currentUser => _currentUser;
  String? get token => _token;
  DateTime? get expiresAt => _expiresAt;

  bool get isLoggedIn => _token != null && _currentUser != null;

  /// [tryAutoLogin] bitene kadar true kalır. Router bu sırada yönlendirme
  /// yapmamalı, yoksa oturumu açık kullanıcı bir an giriş ekranını görür.
  bool get isInitializing => _isInitializing;

  Future<void> login(String email, String password) async {
    final result = await _authService.login(email, password);
    await _startSession(result);
  }

  Future<void> register(String fullName, String email, String password) async {
    final result = await _authService.register(fullName, email, password);
    await _startSession(result);
  }

  Future<void> logout() async {
    _clearSession();
    notifyListeners();
    await _tokenStorage.deleteToken();
  }

  /// Uygulama açılışında çalışır: kayıtlı oturum varsa ve süresi dolmamışsa
  /// kullanıcıyı tekrar giriş yaptırmadan oturumu açar.
  Future<void> tryAutoLogin() async {
    try {
      final session = await _tokenStorage.readSession();
      if (session != null && session.expiresAt.isAfter(DateTime.now())) {
        _applySession(session);
      } else {
        // Oturum yok, bozuk ya da süresi dolmuş: kalıntıları temizle.
        await _tokenStorage.deleteToken();
      }
    } catch (_) {
      // Güvenli depolama okunamadıysa giriş ekranına düşmek yeterli.
      _clearSession();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _startSession(AuthResult result) async {
    await _tokenStorage.saveSession(result);
    _applySession(result);
    notifyListeners();
  }

  void _applySession(AuthResult result) {
    _token = result.token;
    _expiresAt = result.expiresAt;
    _currentUser = result.user;
    _scheduleExpiry(result.expiresAt);
  }

  /// Uygulama açıkken token süresi dolarsa otomatik çıkış yapar.
  void _scheduleExpiry(DateTime expiresAt) {
    _expiryTimer?.cancel();
    final remaining = expiresAt.difference(DateTime.now());
    _expiryTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      logout,
    );
  }

  void _clearSession() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _token = null;
    _expiresAt = null;
    _currentUser = null;
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
