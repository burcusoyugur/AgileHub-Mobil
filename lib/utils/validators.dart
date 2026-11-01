/// Formlarda ortak kullanılan doğrulama fonksiyonları.
///
/// Giriş ve kayıt ekranları aynı kuralları kullansın diye burada toplandı.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _digitPattern = RegExp(r'\d');

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Ad soyad boş olamaz';
    if (name.length < 3) return 'Ad soyad en az 3 karakter olmalı';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'E-posta boş olamaz';
    if (!_emailPattern.hasMatch(email)) return 'Geçerli bir e-posta girin';
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Şifre boş olamaz';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalı';
    if (!_digitPattern.hasMatch(password)) {
      return 'Şifre en az bir rakam içermeli';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Şifre tekrarı boş olamaz';
    if (value != password) return 'Şifreler eşleşmiyor';
    return null;
  }
}
