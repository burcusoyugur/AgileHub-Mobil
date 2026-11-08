import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

/// Ortak API'ye istek atan tek sınıf.
///
/// Her isteğe giriş yapan kullanıcının JWT'sini (`Authorization: Bearer ...`)
/// ekler, cevabı JSON olarak çözer ve hataları ekranda gösterilecek Türkçe
/// mesajlı [ApiException]'a çevirir. Servisler (`ApiProjectService`,
/// `ApiSprintService`...) HTTP ayrıntılarıyla uğraşmaz, sadece bunu kullanır.
class ApiClient {
  ApiClient({
    required String? Function() tokenProvider,
    http.Client? httpClient,
    void Function()? onUnauthorized,
    String? baseUrl,
  }) : _tokenProvider = tokenProvider,
       _http = httpClient ?? http.Client(),
       _onUnauthorized = onUnauthorized,
       _baseUrlOverride = baseUrl;

  /// Her istekte güncel token'ı okumak için kullanılır (oturum değişebilir).
  final String? Function() _tokenProvider;
  final http.Client _http;

  /// Sunucu 401 döndüğünde (token geçersiz / süresi dolmuş) çağrılır.
  final void Function()? _onUnauthorized;

  /// Testlerde sahte bir adres vermek için. Verilmezse [ApiConfig.baseUrl]
  /// kullanılır; o da ilk istekte okunur (uygulama açılışında değil), böylece
  /// sahte veriyle çalışırken platform kontrolü hiç yapılmaz.
  final String? _baseUrlOverride;
  String get _baseUrl => _baseUrlOverride ?? ApiConfig.baseUrl;

  static const Duration timeout = Duration(seconds: 10);

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Object? body) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, Object? body) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  void close() => _http.close();

  Map<String, String> _headers({required bool hasBody}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (hasBody) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _send(String method, String path, {Object? body}) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll(_headers(hasBody: body != null));
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      final streamed = await _http.send(request).timeout(timeout);
      response = await http.Response.fromStream(streamed).timeout(timeout);
    } on TimeoutException {
      throw const ApiException('Sunucuya ulaşılamadı');
    } on SocketException {
      throw const ApiException('Sunucuya ulaşılamadı');
    } on http.ClientException {
      throw const ApiException('Sunucuya ulaşılamadı');
    }

    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final code = response.statusCode;

    if (code >= 200 && code < 300) {
      if (response.bodyBytes.isEmpty) return null;
      try {
        // utf8.decode: Türkçe karakterler bozulmasın diye baytlardan çözülür.
        return jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw ApiException('Beklenmeyen bir hata oluştu', statusCode: code);
      }
    }

    switch (code) {
      case 401:
        _onUnauthorized?.call();
        throw const ApiException(
          'Oturumun süresi doldu, lütfen tekrar giriş yap',
          statusCode: 401,
        );
      case 403:
        throw const ApiException('Bu kayda erişim yetkin yok', statusCode: 403);
      case 404:
        throw const ApiException('Kayıt bulunamadı', statusCode: 404);
      default:
        throw ApiException('Beklenmeyen bir hata oluştu', statusCode: code);
    }
  }
}
