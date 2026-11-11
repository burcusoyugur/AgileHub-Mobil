import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/models/project.dart';
import 'package:agilehub_mobil/models/user.dart';

// Web API'nin gerçekte döndürdüğü gövdelere benzeyen örnekler. Alan adları
// AgileHub/Models/ApiDtolari.cs'teki DTO'larla aynıdır; tarihler sunucudan
// saat dilimi (Z) olmadan yerel saat olarak gelir.
Map<String, dynamic> _decode(String govde) =>
    jsonDecode(govde) as Map<String, dynamic>;

void main() {
  group('Project.fromJson', () {
    test('ProjeDto alanlarının hepsini okur', () {
      final proje = Project.fromJson(
        _decode('''
        {
          "id": 2,
          "ad": "AgileHub Mobil",
          "aciklama": "Scrum takibinin Flutter istemcisi",
          "olusturmaTarihi": "2026-10-05T14:30:00",
          "olusturanKullaniciId": "3f1c9a2e-7b4d-4e8a-9c11-2a6b5d8e0f47",
          "olusturanKullaniciAdi": "Esra Meriç Topaktaş"
        }
        '''),
      );

      expect(proje.id, 2);
      expect(proje.name, 'AgileHub Mobil');
      expect(proje.description, 'Scrum takibinin Flutter istemcisi');
      expect(proje.createdAt, DateTime(2026, 10, 5, 14, 30));
      expect(proje.createdAt.isUtc, isFalse);
      expect(proje.createdByUserId, '3f1c9a2e-7b4d-4e8a-9c11-2a6b5d8e0f47');
      expect(proje.createdByUserName, 'Esra Meriç Topaktaş');
    });

    test('açıklama ve oluşturan adı boş gelebilir', () {
      final proje = Project.fromJson(
        _decode('''
        {
          "id": 3,
          "ad": "Kütüphane Otomasyonu",
          "aciklama": null,
          "olusturmaTarihi": "2026-11-01T09:00:00",
          "olusturanKullaniciId": "kullanici-1",
          "olusturanKullaniciAdi": null
        }
        '''),
      );

      expect(proje.description, isNull);
      expect(proje.createdByUserName, isNull);
    });

    test('saniye kesirli tarihi okur', () {
      final proje = Project.fromJson(
        _decode('''
        {
          "id": 1,
          "ad": "AgileHub Web",
          "aciklama": null,
          "olusturmaTarihi": "2026-10-01T08:15:42.1234567",
          "olusturanKullaniciId": "kullanici-1",
          "olusturanKullaniciAdi": "Burcu Soyuğur"
        }
        '''),
      );

      expect(proje.createdAt.year, 2026);
      expect(proje.createdAt.second, 42);
    });

    test('toJson ile geri dönüşümde alanlar korunur', () {
      final ilk = Project(
        id: 7,
        name: 'Deneme',
        description: 'Açıklama',
        createdAt: DateTime(2026, 11, 12, 10),
        createdByUserId: 'kullanici-7',
        createdByUserName: 'Erkim Berk Ünsal',
      );

      final kopya = Project.fromJson(ilk.toJson());

      expect(kopya.id, ilk.id);
      expect(kopya.name, ilk.name);
      expect(kopya.description, ilk.description);
      expect(kopya.createdAt, ilk.createdAt);
      expect(kopya.createdByUserId, ilk.createdByUserId);
      expect(kopya.createdByUserName, ilk.createdByUserName);
    });
  });

  group('User.fromJson', () {
    test('KullaniciDto alanlarını okur ve tam adı birleştirir', () {
      final kullanici = User.fromJson(
        _decode('''
        {
          "id": "8a7d6c5b-4e3f-2a1b-0c9d-8e7f6a5b4c3d",
          "email": "admin@agilehub.local",
          "ad": "Gözde",
          "soyad": "Sarı"
        }
        '''),
      );

      expect(kullanici.id, '8a7d6c5b-4e3f-2a1b-0c9d-8e7f6a5b4c3d');
      expect(kullanici.email, 'admin@agilehub.local');
      expect(kullanici.firstName, 'Gözde');
      expect(kullanici.lastName, 'Sarı');
      expect(kullanici.fullName, 'Gözde Sarı');
    });

    test('proje üyeleri listesini (KullaniciDto[]) okur', () {
      final liste = jsonDecode('''
        [
          {"id": "k1", "email": "erkim@agilehub.local", "ad": "Erkim Berk", "soyad": "Ünsal"},
          {"id": "k2", "email": "burcu@agilehub.local", "ad": "Şahyan Burcu", "soyad": "Soyuğur"}
        ]
        ''') as List<dynamic>;

      final uyeler = liste
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(uyeler.map((u) => u.fullName), [
        'Erkim Berk Ünsal',
        'Şahyan Burcu Soyuğur',
      ]);
    });
  });
}
