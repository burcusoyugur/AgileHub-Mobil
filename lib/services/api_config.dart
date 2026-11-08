import 'dart:io';

/// Ortak API'ye bağlantı ayarları.
class ApiConfig {
  ApiConfig._();

  static const int port = int.fromEnvironment('API_PORT', defaultValue: 5203);

  /// API 4. haftada hazır olana kadar sahte servis kullanılır. Gerçek API
  /// için: flutter run --dart-define=USE_MOCK_AUTH=false
  static const bool useMockAuth =
      bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: true);

  /// Proje ve sprint verileri için de 4. haftaya kadar sahte servis
  /// kullanılır. Gerçek API için: flutter run --dart-define=USE_MOCK_DATA=false
  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);

  /// Android emülatöründe bilgisayarın localhost adresi 10.0.2.2'dir.
  static String get baseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:$port' : 'http://localhost:$port';
}
