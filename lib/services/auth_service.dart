import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'api_config.dart';
import 'api_exception.dart';

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
/// API'ye istek atar. Hata durumunda ekranda gösterilecek Türkçe mesajlı
/// [AuthException] fırlatır.
class AuthService {
  /// [httpClient], [baseUrl] ve [useMock] testlerde sahte sunucu vermek
  /// içindir; uygulamada verilmez.
  AuthService({http.Client? httpClient, String? baseUrl, bool? useMock})
    : _http = httpClient,
      _baseUrlOverride = baseUrl,
      _useMock = useMock ?? ApiConfig.useMockAuth;

  static const String demoEmail = 'admin@agilehub.local';

  static const String connectionError = 'Sunucuya ulaşılamadı';
  static const String serverError =
      'Sunucuda bir hata oluştu, lütfen tekrar dene';
  static const String unexpectedError = 'Beklenmeyen bir hata oluştu';
  static const String duplicateEmail = 'Bu e-posta ile kayıtlı bir hesap var';
  static const String wrongCredentials = 'E-posta veya şifre hatalı';

  static const Duration timeout = Duration(seconds: 10);

  final http.Client? _http;
  final String? _baseUrlOverride;
  final bool _useMock;

  String get _baseUrl => _baseUrlOverride ?? ApiConfig.baseUrl;

  Future<AuthResult> login(String email, String password) async {
    if (_useMock) return _mockLogin(email);

    final response = await _post('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });

    if (response.statusCode == 200) return _parse(response);
    if (response.statusCode == 401) {
      // Hesap kilitlendiyse sunucu "detail" ile nedenini söyler;
      // yanlış şifrede detail yoktur.
      throw AuthException(
        problemMessage(response.bodyBytes) ?? wrongCredentials,
      );
    }
    throw AuthException(_errorMessage(response, 'Giriş yapılamadı'));
  }

  Future<AuthResult> register(
    String fullName,
    String email,
    String password,
  ) async {
    if (_useMock) return _mockRegister(fullName, email);

    final response = await _post('/api/auth/register', {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    });

    if (response.statusCode == 200) return _parse(response);
    if (response.statusCode == 409) {
      throw const AuthException(duplicateEmail);
    }
    throw AuthException(_errorMessage(response, 'Kayıt yapılamadı'));
  }

  /// 400'de sunucunun Türkçe doğrulama mesajını (ör. "Şifre en az 6 karakter
  /// olmalıdır."), 500 ve üstünde sunucu hatası mesajını döndürür.
  String _errorMessage(http.Response response, String fallback) {
    final code = response.statusCode;
    if (code == 400) {
      return problemMessage(response.bodyBytes) ??
          'Gönderilen bilgiler geçersiz';
    }
    if (code >= 500) return serverError;
    return '$fallback, lütfen tekrar dene';
  }

  Future<http.Response> _post(String path, Map<String, String> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    const headers = {'Content-Type': 'application/json; charset=utf-8'};
    final encoded = jsonEncode(body);
    try {
      final client = _http;
      final future = client == null
          ? http.post(uri, headers: headers, body: encoded)
          : client.post(uri, headers: headers, body: encoded);
      return await future.timeout(timeout);
    } on SocketException {
      throw const AuthException(connectionError);
    } on TimeoutException {
      throw const AuthException(connectionError);
    } on http.ClientException {
      throw const AuthException(connectionError);
    }
  }

  AuthResult _parse(http.Response response) {
    try {
      return AuthResult.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } catch (_) {
      // Gövde JSON değil ya da beklenen alanlar yok: uygulama çökmesin.
      throw const AuthException(unexpectedError);
    }
  }

  Future<AuthResult> _mockLogin(String email) async {
    // Gerçek bir sunucuya istek atıyormuş gibi kısa bir bekleme.
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.trim().toLowerCase() != demoEmail) {
      throw const AuthException(wrongCredentials);
    }
    return _mockResult(email.trim(), 'Demo', 'Kullanıcı');
  }

  Future<AuthResult> _mockRegister(String fullName, String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Demo hesabı zaten kayıtlı kabul ediliyor.
    if (email.trim().toLowerCase() == demoEmail) {
      throw const AuthException(duplicateEmail);
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
