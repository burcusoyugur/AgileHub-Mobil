import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agilehub_mobil/services/auth_service.dart';

const _baseUrl = 'http://test.local';

/// Gerçek API'yle çalışan (mock olmayan) servis; istekleri [handler] cevaplar.
AuthService _service(MockClientHandler handler) => AuthService(
  httpClient: MockClient(handler),
  baseUrl: _baseUrl,
  useMock: false,
);

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Matcher _authError(String message) =>
    isA<AuthException>().having((e) => e.message, 'message', message);

const _tokenYaniti = {
  'token': 'jwt',
  'expiresAt': '2026-11-20T10:00:00Z',
  'user': {
    'id': 'u1',
    'email': 'ayse@ornek.com',
    'ad': 'Ayşe',
    'soyad': 'Yılmaz',
  },
};

void main() {
  group('AuthService.login', () {
    test('200: token ve kullanıcıyı döndürür', () async {
      late http.Request gelen;
      final service = _service((request) async {
        gelen = request;
        return _json(_tokenYaniti, 200);
      });

      final result = await service.login(' ayse@ornek.com ', 'Sifre123');

      expect(gelen.url.toString(), '$_baseUrl/api/auth/login');
      expect(jsonDecode(gelen.body), {
        'email': 'ayse@ornek.com',
        'password': 'Sifre123',
      });
      expect(result.token, 'jwt');
      expect(result.user.email, 'ayse@ornek.com');
    });

    test('401: "E-posta veya şifre hatalı"', () async {
      final service = _service(
        (_) async => _json({
          'title': 'E-posta veya şifre hatalı',
          'status': 401,
        }, 401),
      );

      await expectLater(
        service.login('a@b.com', 'x'),
        throwsA(_authError('E-posta veya şifre hatalı')),
      );
    });

    test('401 gövdesiz de olsa "E-posta veya şifre hatalı"', () async {
      final service = _service((_) async => http.Response('', 401));

      await expectLater(
        service.login('a@b.com', 'x'),
        throwsA(_authError('E-posta veya şifre hatalı')),
      );
    });

    test('401 kilitli hesap: sunucunun açıklamasını gösterir', () async {
      final service = _service(
        (_) async => _json({
          'title': 'Hesap geçici olarak kilitlendi',
          'status': 401,
          'detail': 'Çok fazla hatalı deneme yapıldı. Birkaç dakika sonra tekrar dene.',
        }, 401),
      );

      await expectLater(
        service.login('a@b.com', 'x'),
        throwsA(
          _authError(
            'Çok fazla hatalı deneme yapıldı. Birkaç dakika sonra tekrar dene.',
          ),
        ),
      );
    });

    test('400: sunucunun Türkçe doğrulama mesajını gösterir', () async {
      final service = _service(
        (_) async => _json({
          'title': 'One or more validation errors occurred.',
          'status': 400,
          'errors': {
            'Email': ['Geçerli bir e-posta adresi gir.'],
          },
        }, 400),
      );

      await expectLater(
        service.login('eposta-degil', 'x'),
        throwsA(_authError('Geçerli bir e-posta adresi gir.')),
      );
    });

    test('500: sunucu hatası mesajı', () async {
      final service = _service((_) async => http.Response('', 500));

      await expectLater(
        service.login('a@b.com', 'x'),
        throwsA(_authError('Sunucuda bir hata oluştu, lütfen tekrar dene')),
      );
    });

    test('bağlantı hatası: "Sunucuya ulaşılamadı"', () async {
      final service = _service(
        (_) async => throw http.ClientException('bağlantı reddedildi'),
      );

      await expectLater(
        service.login('a@b.com', 'x'),
        throwsA(_authError('Sunucuya ulaşılamadı')),
      );
    });

    test('200 ama gövde JSON değil: çökmez, beklenmeyen hata', () async {
      final service = _service((_) async => http.Response('<html>', 200));

      await expectLater(
        service.login('a@b.com', 'x'),
        throwsA(_authError('Beklenmeyen bir hata oluştu')),
      );
    });
  });

  group('AuthService.register', () {
    test('200: yeni oturumu döndürür', () async {
      late http.Request gelen;
      final service = _service((request) async {
        gelen = request;
        return _json(_tokenYaniti, 200);
      });

      final result = await service.register(
        ' Ayşe Yılmaz ',
        'ayse@ornek.com',
        'Sifre123',
      );

      expect(gelen.url.toString(), '$_baseUrl/api/auth/register');
      expect(jsonDecode(gelen.body)['fullName'], 'Ayşe Yılmaz');
      expect(result.user.firstName, 'Ayşe');
    });

    test('409: "Bu e-posta ile kayıtlı bir hesap var"', () async {
      final service = _service(
        (_) async => _json({'status': 409}, 409),
      );

      await expectLater(
        service.register('Ayşe Yılmaz', 'admin@agilehub.local', 'Sifre123'),
        throwsA(_authError('Bu e-posta ile kayıtlı bir hesap var')),
      );
    });

    test('400: şifre kuralı hatasını (Identity) gösterir', () async {
      final service = _service(
        (_) async => _json({
          'status': 400,
          'errors': {
            'PasswordTooShort': ['Şifre en az 6 karakter olmalıdır.'],
            'PasswordRequiresDigit': ['Şifre en az bir rakam içermelidir.'],
          },
        }, 400),
      );

      await expectLater(
        service.register('Ayşe Yılmaz', 'ayse@ornek.com', '123'),
        throwsA(_authError('Şifre en az 6 karakter olmalıdır.')),
      );
    });

    test('400 mesajsız: "Gönderilen bilgiler geçersiz"', () async {
      final service = _service((_) async => http.Response('', 400));

      await expectLater(
        service.register('Ayşe Yılmaz', 'ayse@ornek.com', '123'),
        throwsA(_authError('Gönderilen bilgiler geçersiz')),
      );
    });
  });
}
