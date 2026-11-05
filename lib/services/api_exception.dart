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

  @override
  String toString() => message;
}
