import 'dart:convert';

/// Proje, sprint ve görev servislerinin fırlattığı hata.
///
/// [message] ekranda doğrudan gösterilecek Türkçe metindir. [statusCode]
/// API'den gelen HTTP kodudur; sunucuya hiç ulaşılamadıysa `null` olur.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;
  bool get isForbidden => statusCode == 403;
  bool get isUnauthorized => statusCode == 401;

  /// Gönderilen bilgi sunucunun kurallarına uymadı (400).
  bool get isValidation => statusCode == 400;

  /// Aynı kayıt zaten var (409).
  bool get isConflict => statusCode == 409;

  /// Sunucunun kendi kodunda bir hata oluştu (500 ve üstü).
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Sunucuya hiç ulaşılamadı: internet yok, sunucu kapalı ya da zaman aşımı.
  bool get isConnectionError => statusCode == null;

  @override
  String toString() => message;
}

/// API'nin hata gövdesinden (ProblemDetails) ekranda gösterilecek mesajı çıkarır.
///
/// Sıra: önce `detail` (ör. "Başlık zorunludur."), yoksa `errors` içindeki ilk
/// mesaj (ör. "Geçerli bir e-posta adresi gir."). İkisi de yoksa ya da gövde
/// JSON değilse `null` döner; çağıran kendi varsayılan mesajını kullanır.
/// `title` kullanılmaz: doğrulama hatalarında İngilizce gelir.
String? problemMessage(List<int> bodyBytes) {
  if (bodyBytes.isEmpty) return null;

  final Object? body;
  try {
    body = jsonDecode(utf8.decode(bodyBytes));
  } on FormatException {
    // HTML hata sayfası, boş metin vb. Uygulama çökmesin, varsayılan mesaj kullanılsın.
    return null;
  }
  if (body is! Map<String, dynamic>) return null;

  final detail = body['detail'];
  if (detail is String && detail.trim().isNotEmpty) return detail.trim();

  final errors = body['errors'];
  if (errors is Map) {
    for (final value in errors.values) {
      if (value is List) {
        for (final item in value) {
          if (item is String && item.trim().isNotEmpty) return item.trim();
        }
      } else if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
  }
  return null;
}
