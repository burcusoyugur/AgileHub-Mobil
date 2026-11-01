/// Giriş ve kayıt işlemlerini yapan servis.
///
/// Şimdilik SAHTE (mock) bir servis: API 4. haftada hazır olacak.
/// O zaman sadece [login] ve [register] metotlarının içi gerçek API
/// çağrısıyla değişecek; ekranlarda hiçbir şey değiştirmek gerekmeyecek.
class AuthService {
  static const String demoEmail = 'admin@agilehub.local';

  /// Giriş başarılıysa true, değilse false döner.
  Future<bool> login(String email, String password) async {
    // Gerçek bir sunucuya istek atıyormuş gibi kısa bir bekleme.
    await Future.delayed(const Duration(milliseconds: 800));
    return email.trim().toLowerCase() == demoEmail;
  }

  /// Kayıt başarılıysa true, e-posta zaten kullanılıyorsa false döner.
  Future<bool> register(String fullName, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Demo hesabı zaten kayıtlı kabul ediliyor.
    return email.trim().toLowerCase() != demoEmail;
  }
}
