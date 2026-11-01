import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import 'auth_service.dart';

/// Oturum bilgisini (token, bitiş zamanı, kullanıcı) cihazda güvenli saklar.
///
/// Uygulama yeniden açıldığında oturumu geri yüklemek için hem token'a hem
/// de süre kontrolü ve kullanıcı bilgisi için diğer alanlara ihtiyaç var.
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _expiresAtKey = 'auth_expires_at';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  /// Token ile birlikte bitiş zamanını ve kullanıcı bilgisini de siler.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _userKey);
  }

  /// Giriş/kayıt sonrası gelen oturumun tamamını kaydeder.
  Future<void> saveSession(AuthResult result) async {
    await saveToken(result.token);
    await _storage.write(
      key: _expiresAtKey,
      value: result.expiresAt.toIso8601String(),
    );
    await _storage.write(
      key: _userKey,
      value: jsonEncode(result.user.toJson()),
    );
  }

  /// Kayıtlı oturumu döner. Eksik ya da bozuk veri varsa `null` döner.
  Future<AuthResult?> readSession() async {
    final token = await readToken();
    final expiresAt = await _storage.read(key: _expiresAtKey);
    final user = await _storage.read(key: _userKey);
    if (token == null || expiresAt == null || user == null) return null;

    try {
      return AuthResult(
        token: token,
        expiresAt: DateTime.parse(expiresAt),
        user: User.fromJson(jsonDecode(user) as Map<String, dynamic>),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
