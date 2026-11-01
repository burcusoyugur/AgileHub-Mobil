/// Giriş işlemlerini yapan servis.
///
/// Şimdilik SAHTE (mock) bir servis: API 4. haftada hazır olacak.
/// O zaman sadece [login] metodunun içi gerçek API çağrısıyla değişecek;
/// giriş ekranında hiçbir şey değiştirmek gerekmeyecek.
class AuthService {
  static const String demoEmail = 'admin@agilehub.local';

  /// Giriş başarılıysa true, değilse false döner.
  Future<bool> login(String email, String password) async {
    // Gerçek bir sunucuya istek atıyormuş gibi kısa bir bekleme.
    await Future.delayed(const Duration(milliseconds: 800));
    return email.trim().toLowerCase() == demoEmail;
  }
}
