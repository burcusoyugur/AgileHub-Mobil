import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agilehub_mobil/services/api_client.dart';
import 'package:agilehub_mobil/services/api_exception.dart';

const _baseUrl = 'http://test.local';

/// Sahte sunucu: her isteği [handler] cevaplar, gerçek ağa çıkılmaz.
ApiClient _client(
  MockClientHandler handler, {
  String? token = 'abc123',
  void Function()? onUnauthorized,
}) {
  return ApiClient(
    tokenProvider: () => token,
    httpClient: MockClient(handler),
    onUnauthorized: onUnauthorized,
    baseUrl: _baseUrl,
  );
}

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

TypeMatcher<ApiException> _apiException(String message, int? statusCode) =>
    isA<ApiException>()
    .having((e) => e.message, 'message', message)
    .having((e) => e.statusCode, 'statusCode', statusCode);

void main() {
  group('ApiClient', () {
    test('Bearer token ve Accept başlığını gönderir, adresi doğru kurar',
        () async {
      late http.Request gelen;
      final client = _client((request) async {
        gelen = request;
        return _json([], 200);
      });

      await client.get('/api/projeler');

      expect(gelen.method, 'GET');
      expect(gelen.url.toString(), '$_baseUrl/api/projeler');
      expect(gelen.headers['Authorization'], 'Bearer abc123');
      expect(gelen.headers['Accept'], 'application/json');
    });

    test('token yoksa Authorization başlığı göndermez', () async {
      late http.Request gelen;
      final client = _client((request) async {
        gelen = request;
        return _json([], 200);
      }, token: null);

      await client.get('/api/projeler');

      expect(gelen.headers.containsKey('Authorization'), isFalse);
    });

    test('200 cevabını JSON olarak çözer (Türkçe karakterler dahil)',
        () async {
      final client = _client(
        (_) async => _json([
          {'id': 1, 'ad': 'Kütüphane Otomasyonu'},
        ], 200),
      );

      final sonuc = await client.get('/api/projeler') as List<dynamic>;

      expect(sonuc, hasLength(1));
      expect((sonuc.first as Map<String, dynamic>)['ad'], 'Kütüphane Otomasyonu');
    });

    test('POST gövdesini JSON olarak gönderir', () async {
      late http.Request gelen;
      final client = _client((request) async {
        gelen = request;
        return _json({'id': 5}, 201);
      });

      await client.post('/api/gorevler', {'baslik': 'Deneme'});

      expect(gelen.method, 'POST');
      expect(jsonDecode(gelen.body), {'baslik': 'Deneme'});
      expect(gelen.headers['Content-Type'], startsWith('application/json'));
    });

    test('401 oturum hatasına çevrilir ve onUnauthorized çağrılır', () async {
      var cikisYapildi = false;
      final client = _client(
        (_) async => http.Response('', 401),
        onUnauthorized: () => cikisYapildi = true,
      );

      await expectLater(
        client.get('/api/projeler'),
        throwsA(
          _apiException('Oturumun süresi doldu, lütfen tekrar giriş yap', 401),
        ),
      );
      expect(cikisYapildi, isTrue);
    });

    test('403 yetki hatasına çevrilir', () async {
      final client = _client((_) async => http.Response('', 403));

      await expectLater(
        client.get('/api/projeler/1'),
        throwsA(_apiException('Bu kayda erişim yetkin yok', 403)),
      );
    });

    test('404 "Kayıt bulunamadı" hatasına çevrilir', () async {
      final client = _client((_) async => http.Response('', 404));

      await expectLater(
        client.get('/api/projeler/999'),
        throwsA(_apiException('Kayıt bulunamadı', 404)),
      );
    });

    test('400: sunucunun "detail" mesajını gösterir', () async {
      final client = _client(
        (_) async => _json({
          'title': 'Geçersiz istek',
          'status': 400,
          'detail': 'Sprint bitmiş, görev eklenemez.',
        }, 400),
      );

      await expectLater(
        client.post('/api/projeler/1/gorevler', {}),
        throwsA(
          _apiException('Sprint bitmiş, görev eklenemez.', 400)
              .having((e) => e.isValidation, 'isValidation', true),
        ),
      );
    });

    test('400: detail yoksa "errors" içindeki ilk mesajı gösterir', () async {
      final client = _client(
        (_) async => _json({
          'title': 'One or more validation errors occurred.',
          'status': 400,
          'errors': {
            'Baslik': ['Başlık zorunludur.'],
          },
        }, 400),
      );

      await expectLater(
        client.post('/api/projeler/1/gorevler', {}),
        throwsA(_apiException('Başlık zorunludur.', 400)),
      );
    });

    test('400: mesaj yoksa varsayılan mesajı gösterir', () async {
      final client = _client((_) async => _json({'status': 400}, 400));

      await expectLater(
        client.post('/api/projeler/1/gorevler', {}),
        throwsA(_apiException('Gönderilen bilgiler geçersiz', 400)),
      );
    });

    test('400: gövde JSON değilse çökmez, varsayılan mesajı gösterir',
        () async {
      final client = _client(
        (_) async => http.Response('<html>Bad Request</html>', 400),
      );

      await expectLater(
        client.post('/api/projeler/1/gorevler', {}),
        throwsA(_apiException('Gönderilen bilgiler geçersiz', 400)),
      );
    });

    test('409 "Bu kayıt zaten var" hatasına çevrilir', () async {
      final client = _client((_) async => _json({'status': 409}, 409));

      await expectLater(
        client.post('/api/projeler/1/gorevler', {}),
        throwsA(
          _apiException('Bu kayıt zaten var', 409)
              .having((e) => e.isConflict, 'isConflict', true),
        ),
      );
    });

    test('500 ve üstü sunucu hatasına çevrilir (gövde boş da olsa)', () async {
      for (final code in [500, 502, 503]) {
        final client = _client((_) async => http.Response('', code));

        await expectLater(
          client.get('/api/projeler'),
          throwsA(
            _apiException('Sunucuda bir hata oluştu, lütfen tekrar dene', code)
                .having((e) => e.isServerError, 'isServerError', true),
          ),
        );
      }
    });

    test('diğer hata kodları beklenmeyen hataya çevrilir', () async {
      final client = _client((_) async => http.Response('', 418));

      await expectLater(
        client.get('/api/projeler'),
        throwsA(_apiException('Beklenmeyen bir hata oluştu', 418)),
      );
    });

    test('200 cevabı JSON değilse çökmez, beklenmeyen hataya çevrilir',
        () async {
      final client = _client((_) async => http.Response('merhaba', 200));

      await expectLater(
        client.get('/api/projeler'),
        throwsA(_apiException('Beklenmeyen bir hata oluştu', 200)),
      );
    });

    test('bağlantı hatası "Sunucuya ulaşılamadı" olur', () async {
      final client = _client(
        (_) async => throw http.ClientException('bağlantı reddedildi'),
      );

      await expectLater(
        client.get('/api/projeler'),
        throwsA(
          _apiException('Sunucuya ulaşılamadı', null)
              .having((e) => e.isConnectionError, 'isConnectionError', true),
        ),
      );
    });
  });

  group('problemMessage', () {
    List<int> bytes(Object body) => utf8.encode(jsonEncode(body));

    test('önce detail, sonra errors içindeki ilk mesaj', () {
      expect(
        problemMessage(bytes({'detail': 'A', 'errors': {'x': ['B']}})),
        'A',
      );
      expect(problemMessage(bytes({'errors': {'x': ['B', 'C']}})), 'B');
    });

    test('İngilizce title kullanılmaz', () {
      expect(problemMessage(bytes({'title': 'Bad Request'})), isNull);
    });

    test('boş, JSON olmayan veya liste gövdede null döner', () {
      expect(problemMessage([]), isNull);
      expect(problemMessage(utf8.encode('<html>')), isNull);
      expect(problemMessage(bytes(['detail'])), isNull);
    });
  });
}
