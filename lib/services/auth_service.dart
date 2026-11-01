import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'api_config.dart';

/// Giriş ve kayıt sonrası API'nin döndürdüğü oturum bilgisi.
class AuthResult {
  final String token;
  final DateTime expiresAt;
  final User user;

  const AuthResult({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Ekranda gösterilecek Türkçe hata mesajını taşır.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}

/// Giriş ve kayıt işlemlerini yapan servis.
///
/// [ApiConfig.useMockAuth] açıkken SAHTE (mock) çalışır, kapalıyken ortak
/// API'ye istek atar. Hata durumunda [AuthException] fırlatır.
class AuthService {
  static const String demoEmail = 'admin@agilehub.local';

  Future<AuthResult> login(String email, String password) async {
    if (ApiConfig.useMockAuth) return _mockLogin(email);

    final response = await _post('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });

    if (response.statusCode == 200) return _parse(response);
    if (response.statusCode == 401) {
      throw const AuthException('E-posta veya şifre hatalı');
    }
    throw const AuthException('Giriş yapılamadı, lütfen tekrar deneyin');
  }

  Future<AuthResult> register(
    String fullName,
    String email,
    String password,
  ) async {
    if (ApiConfig.useMockAuth) return _mockRegister(fullName, email);

    final response = await _post('/api/auth/register', {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    });

    if (response.statusCode == 200) return _parse(response);
    if (response.statusCode == 409) {
      throw const AuthException('Bu e-posta adresi zaten kayıtlı');
    }
    throw const AuthException('Kayıt yapılamadı, lütfen tekrar deneyin');
  }

  Future<http.Response> _post(String path, Map<String, String> body) async {
    try {
      return await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const AuthException('Sunucuya ulaşılamadı');
    } on TimeoutException {
      throw const AuthException('Sunucuya ulaşılamadı');
    } on http.ClientException {
      throw const AuthException('Sunucuya ulaşılamadı');
    }
  }

  AuthResult _parse(http.Response response) {
    return AuthResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AuthResult> _mockLogin(String email) async {
    // Gerçek bir sunucuya istek atıyormuş gibi kısa bir bekleme.
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.trim().toLowerCase() != demoEmail) {
      throw const AuthException('E-posta veya şifre hatalı');
    }
    return _mockResult(email.trim(), 'Demo', 'Kullanıcı');
  }

  Future<AuthResult> _mockRegister(String fullName, String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Demo hesabı zaten kayıtlı kabul ediliyor.
    if (email.trim().toLowerCase() == demoEmail) {
      throw const AuthException('Bu e-posta adresi zaten kayıtlı');
    }
    return _mockResult(email.trim(), fullName.trim(), '');
  }

  AuthResult _mockResult(String email, String firstName, String lastName) {
    return AuthResult(
      token: 'sahte-token',
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      user: User(
        id: 'demo-kullanici',
        email: email,
        firstName: firstName,
        lastName: lastName,
      ),
    );
  }
}
