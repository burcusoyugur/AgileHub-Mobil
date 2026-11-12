import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agilehub_mobil/models/task.dart';
import 'package:agilehub_mobil/services/api_client.dart';
import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/services/api_task_service.dart';

const _baseUrl = 'http://test.local';

/// Gelen istekleri [istekler]e kaydeden sahte sunucu. Yol → cevap eşlemesi
/// kullanır; listede olmayan yol 404, [hatalar]daki yol verilen kodu döner.
ApiClient _client(
  Map<String, Object> cevaplar, {
  List<Uri>? istekler,
  Map<String, int> hatalar = const {},
}) {
  return ApiClient(
    tokenProvider: () => 'token',
    baseUrl: _baseUrl,
    httpClient: MockClient((request) async {
      istekler?.add(request.url);
      final hata = hatalar[request.url.path];
      if (hata != null) return http.Response('', hata);
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

Map<String, Object?> _gorev(
  int id, {
  String durum = 'Yapilacak',
  String oncelik = 'Orta',
  int? sprintId = 3,
  String? atanan = 'Gözde Sarı',
  int? storyPoint = 5,
}) => {
  'id': id,
  'projeId': 1,
  'sprintId': sprintId,
  'baslik': 'Görev $id',
  'aciklama': null,
  'durum': durum,
  'oncelik': oncelik,
  'storyPoint': storyPoint,
  'atananKullaniciId': atanan == null ? null : 'kullanici-1',
  'atananKullaniciAdi': atanan,
  'olusturmaTarihi': '2026-11-05T10:00:00',
};

Matcher _apiException(String message, int statusCode) => isA<ApiException>()
    .having((e) => e.message, 'message', message)
    .having((e) => e.statusCode, 'statusCode', statusCode);

void main() {
  group('ApiTaskService', () {
    test('sprintin görevlerini parse eder', () async {
      final servis = ApiTaskService(
        _client({
          '/api/sprintler/3/gorevler': [
            _gorev(1, durum: 'Yapiliyor', oncelik: 'Yuksek'),
            _gorev(2, durum: 'Bitti', oncelik: 'Kritik', atanan: null),
          ],
        }),
      );

      final gorevler = await servis.getSprintTasks(3);

      expect(gorevler.map((t) => t.id), [1, 2]);
      expect(gorevler.first.status, TaskStatus.inProgress);
      expect(gorevler.first.priority, TaskPriority.high);
      expect(gorevler.first.assignedUserName, 'Gözde Sarı');
      expect(gorevler.last.status, TaskStatus.done);
      expect(gorevler.last.priority, TaskPriority.critical);
      expect(gorevler.last.assignedUserName, isNull);
    });

    test('olmayan sprint "Sprint bulunamadı" verir', () async {
      final servis = ApiTaskService(_client({}));

      await expectLater(
        servis.getSprintTasks(999),
        throwsA(_apiException('Sprint bulunamadı', 404)),
      );
    });

    test('proje görevlerini backlogOnly olmadan sorgusuz ister', () async {
      final istekler = <Uri>[];
      final servis = ApiTaskService(
        _client({
          '/api/projeler/1/gorevler': [_gorev(1), _gorev(2, sprintId: null)],
        }, istekler: istekler),
      );

      final gorevler = await servis.getProjectTasks(1);

      expect(gorevler, hasLength(2));
      expect(istekler.single.hasQuery, isFalse);
    });

    test('backlogOnly sadeceBacklog=true ile istenir', () async {
      final istekler = <Uri>[];
      final servis = ApiTaskService(
        _client({
          '/api/projeler/1/gorevler': [_gorev(2, sprintId: null)],
        }, istekler: istekler),
      );

      final gorevler = await servis.getProjectTasks(1, backlogOnly: true);

      expect(istekler.single.queryParameters, {'sadeceBacklog': 'true'});
      expect(gorevler.single.sprintId, isNull);
    });

    test('olmayan projenin görevleri "Proje bulunamadı" verir', () async {
      final servis = ApiTaskService(_client({}));

      await expectLater(
        servis.getProjectTasks(999),
        throwsA(_apiException('Proje bulunamadı', 404)),
      );
    });

    test('tek görevi getirir', () async {
      final servis = ApiTaskService(
        _client({'/api/gorevler/7': _gorev(7, storyPoint: null)}),
      );

      final gorev = await servis.getTask(7);

      expect(gorev.id, 7);
      expect(gorev.title, 'Görev 7');
      expect(gorev.storyPoints, isNull);
    });

    test('olmayan görev "Görev bulunamadı" verir', () async {
      final servis = ApiTaskService(_client({}));

      await expectLater(
        servis.getTask(999),
        throwsA(_apiException('Görev bulunamadı', 404)),
      );
    });

    test('404 dışındaki hatalar olduğu gibi iletilir', () async {
      final servis = ApiTaskService(
        _client({}, hatalar: {'/api/gorevler/7': 403}),
      );

      await expectLater(
        servis.getTask(7),
        throwsA(
          isA<ApiException>().having((e) => e.isForbidden, 'isForbidden', true),
        ),
      );
    });
  });
}
