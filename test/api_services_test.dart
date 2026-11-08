import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agilehub_mobil/models/sprint.dart';
import 'package:agilehub_mobil/services/api_client.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/api_project_service.dart';
import 'package:agilehub_mobil/services/api_sprint_service.dart';

const _baseUrl = 'http://test.local';

/// Yol → cevap eşlemesiyle çalışan sahte sunucu. Listede olmayan yol 404 döner.
ApiClient _client(Map<String, Object> cevaplar) {
  return ApiClient(
    tokenProvider: () => 'token',
    baseUrl: _baseUrl,
    httpClient: MockClient((request) async {
      final govde = cevaplar[request.url.path];
      if (govde == null) return http.Response('', 404);
      return http.Response.bytes(
        utf8.encode(jsonEncode(govde)),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }),
  );
}

Map<String, Object?> _proje(int id, String ad, String tarih) => {
  'id': id,
  'ad': ad,
  'aciklama': null,
  'olusturmaTarihi': tarih,
  'olusturanKullaniciId': 'kullanici-1',
  'olusturanKullaniciAdi': 'Burcu Soyuğur',
};

Map<String, Object?> _sprint(int id, String durum, String baslangic) => {
  'id': id,
  'projeId': 1,
  'ad': 'Sprint $id',
  'hedef': null,
  'baslangicTarihi': baslangic,
  'bitisTarihi': '2026-12-31T00:00:00',
  'durum': durum,
  'toplamStoryPoint': 21,
  'tamamlananStoryPoint': 8,
};

Matcher _apiException(String message, int statusCode) => isA<ApiException>()
    .having((e) => e.message, 'message', message)
    .having((e) => e.statusCode, 'statusCode', statusCode);

void main() {
  group('ApiProjectService', () {
    test('projeleri parse eder ve en yeni oluşturulanı öne alır', () async {
      final servis = ApiProjectService(
        _client({
          '/api/projeler': [
            _proje(1, 'Eski Proje', '2026-10-01T10:00:00'),
            _proje(2, 'Yeni Proje', '2026-11-05T10:00:00'),
          ],
        }),
      );

      final projeler = await servis.getProjects();

      expect(projeler.map((p) => p.name), ['Yeni Proje', 'Eski Proje']);
      expect(projeler.first.createdByUserName, 'Burcu Soyuğur');
    });

    test('tek projeyi getirir', () async {
      final servis = ApiProjectService(
        _client({'/api/projeler/2': _proje(2, 'AgileHub', '2026-11-05T10:00:00')}),
      );

      final proje = await servis.getProject(2);

      expect(proje.id, 2);
      expect(proje.name, 'AgileHub');
    });

    test('olmayan proje "Proje bulunamadı" verir', () async {
      final servis = ApiProjectService(_client({}));

      await expectLater(
        servis.getProject(999),
        throwsA(_apiException('Proje bulunamadı', 404)),
      );
    });
  });

  group('ApiSprintService', () {
    test('projenin sprintlerini parse eder, en yeni başlayanı öne alır',
        () async {
      final servis = ApiSprintService(
        _client({
          '/api/projeler/1/sprintler': [
            _sprint(1, 'Tamamlandı', '2026-10-01T00:00:00'),
            _sprint(2, 'Aktif', '2026-11-02T00:00:00'),
          ],
        }),
      );

      final sprintler = await servis.getSprints(1);

      expect(sprintler.map((s) => s.id), [2, 1]);
      expect(sprintler.first.status, SprintStatus.active);
      expect(sprintler.last.status, SprintStatus.completed);
      expect(sprintler.first.totalStoryPoints, 21);
      expect(sprintler.first.completedStoryPoints, 8);
    });

    test('olmayan sprint "Sprint bulunamadı" verir', () async {
      final servis = ApiSprintService(_client({}));

      await expectLater(
        servis.getSprint(999),
        throwsA(_apiException('Sprint bulunamadı', 404)),
      );
    });

    test('olmayan projenin sprintleri "Proje bulunamadı" verir', () async {
      final servis = ApiSprintService(_client({}));

      await expectLater(
        servis.getSprints(999),
        throwsA(_apiException('Proje bulunamadı', 404)),
      );
    });
  });
}
