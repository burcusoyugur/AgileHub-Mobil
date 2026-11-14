# AgileHub Mobil

AgileHub çevik (Scrum / Kanban) proje takip portalının Flutter ile yazılmış mobil istemcisi. Kullanıcı üyesi olduğu projeleri, sprintleri ve görevleri telefondan takip eder.

BLM4587 dönem projesidir (2026–2027 Güz). Backend web projesiyle ortaktır: [`burcusoyugur/AgileHub`](https://github.com/burcusoyugur/AgileHub) (ASP.NET Core). Mobil uygulama oradaki `/api/...` uçlarına JWT ile bağlanır.

## Ekip

| Ad Soyad | GitHub |
| --- | --- |
| Gözde Sarı | [@gozdesari](https://github.com/gozdesari) |
| Şahyan Burcu Soyuğur | [@burcusoyugur](https://github.com/burcusoyugur) |
| Esra Meriç Topaktaş | [@esrameric](https://github.com/esrameric) |
| Erkim Berk Ünsal | [@erkimberk](https://github.com/erkimberk) |

## Kullanılan teknolojiler

- Flutter 3.x, Dart 3, Material 3
- `go_router` (yönlendirme), `provider` (durum ve bağımlılıklar)
- `http` (API istekleri), `flutter_secure_storage` (oturum bilgisi)
- `fl_chart` (sprint özeti grafikleri)

## Kurulum ve çalıştırma

**1. Depoyu klonlayın ve paketleri indirin**

```
git clone https://github.com/burcusoyugur/AgileHub-Mobil.git
cd AgileHub-Mobil
flutter pub get
```

**2. Uygulamayı çalıştırın**

```
flutter run
```

Varsayılan olarak uygulama **sahte modda** açılır: giriş ve ekranlardaki veriler örnek veridir, sunucu gerekmez.

**Demo hesap (sahte mod):** `admin@agilehub.local`, şifre olarak en az 6 karakterlik herhangi bir değer (ör. `demo123`). Diğer hesaplar için bkz. [Demo hesapları](#demo-hesapları).

## Sahte ve gerçek mod

Mod, `--dart-define` ile seçilir. Ekranlar veriyi her zaman servis arayüzlerinden (`ProjectService`, `SprintService`) alır; hangi servisin kullanılacağı `lib/main.dart`'ta belirlenir.

| Ayar | Varsayılan | Açıklama |
| --- | --- | --- |
| `USE_MOCK_AUTH` | `true` | `false` olunca giriş ve kayıt gerçek API'ye gider (`/api/auth/...`) |
| `USE_MOCK_DATA` | `true` | `false` olunca projeler ve sprintler gerçek API'den gelir (`/api/projeler`, `/api/projeler/{id}/sprintler`, `/api/sprintler/{id}`) |
| `API_PORT` | `5203` | Web API'nin çalıştığı port |

### Örnek veri (sahte mod)

Sahte modda veriler `lib/data/sample_data.dart`'tan gelir ve web'deki demo verisiyle aynıdır:

| Proje | Sprintler | Görevler |
| --- | --- | --- |
| AgileHub Mobil | Sprint 1–2 tamamlandı, **Sprint 3 aktif**, Sprint 4 planlanıyor | Aktif sprintte karışık durumlar, 2 backlog görevi |
| AgileHub Web | Sprint 1 tamamlandı, **Sprint 2 aktif**, "Raporlama denemesi" iptal edildi | Aktif sprintte karışık durumlar, 2 backlog görevi |
| Kütüphane Otomasyonu | Sprint yok (boş durumlar için) | Yalnızca backlog |

- Tarihler uygulamanın açıldığı güne göre hesaplanır: aktif sprintler her gün devam ediyor görünür (bugünden 5 gün önce başlar, 9 gün sonra biter).
- Sprintlerdeki story point toplamları görevlerden hesaplananla aynıdır; `test/sample_data_test.dart` bunu denetler.
- Örnek veriyi değiştirirken web'deki demo verisini de aynı şekilde güncelleyin.

### Gerçek API ile çalıştırma

1. Web projesini kendi README'sindeki adımlarla ayağa kaldırın. Geliştirme ortamında demo verisi ilk açılışta otomatik eklenir:
   ```
   dotnet run --launch-profile http
   ```
   Adres: `http://localhost:5203`.
2. Mobili iki ayarı da kapatarak çalıştırın:
   ```
   flutter run --dart-define=USE_MOCK_AUTH=false --dart-define=USE_MOCK_DATA=false
   ```

Uygulamanın web API'ye bağlandığı adres:

| Cihaz | Adres | Not |
| --- | --- | --- |
| Android emülatörü | `http://10.0.2.2:5203` | Emülatörde bilgisayarın `localhost`'u `10.0.2.2`'dir; uygulama bunu kendisi seçer. |
| iOS simülatörü | `http://localhost:5203` | Ek ayar gerekmez. |
| Gerçek cihaz | – | Şimdilik desteklenmiyor: uygulama Android'de her zaman `10.0.2.2`'ye bağlanır. Bilgisayarın IP adresini verebilmek için `ApiConfig`'e bir adres ayarı eklenmesi gerekiyor. |

- Web API farklı bir portta çalışıyorsa `--dart-define=API_PORT=<port>` ekleyin.
- Oturum cihazda saklanır. Sahte ve gerçek mod arasında geçmeden önce uygulamada çıkış yapın; yoksa önceki moddaki oturumla açılır.

### Demo hesapları

| Mod | Hesap | Şifre | Ne görür |
| --- | --- | --- | --- |
| Sahte | `admin@agilehub.local` | En az 6 karakterlik herhangi bir değer (ör. `demo123`) | 3 proje |
| Gerçek | `admin@agilehub.local` | Web'deki `SeedAdmin:Password` (ekipten isteyin) | 3 proje |
| Gerçek | `gozde@`, `burcu@`, `esra@`, `erkim@agilehub.local` | Yönetici şifresiyle aynı | AgileHub Mobil ve AgileHub Web |
| Gerçek | `test@agilehub.local` | Yönetici şifresiyle aynı | Yalnızca Kütüphane Otomasyonu (diğer projelerde 403 senaryosu) |

Gerçek modda uygulamadaki "Hesap Oluştur" ekranından yeni hesap da açılabilir; yeni hesap hiçbir projenin üyesi olmadığı için Projelerim boş görünür.

## Test ve kod denetimi

```
dart analyze
flutter test
```

Commit'ten önce ikisi de temiz olmalıdır. Proje yolunda Türkçe karakter varsa (ör. `Masaüstü`) `flutter analyze` çökebilir; `dart analyze` aynı denetimi yapar.

`dart format` yalnızca kendi değiştirdiğiniz dosyalarda çalıştırılmalıdır.

## Proje yapısı

| Klasör | İçerik |
| --- | --- |
| `lib/models/` | `Project`, `Sprint`, `Task`, `Comment`, `User`; JSON alan adları web'deki DTO'larla aynı |
| `lib/services/` | Servis arayüzleri, sahte servisler, API bağlantısı ve oturum (`AuthService`, `TokenStorage`) |
| `lib/data/` | Sahte servislerin kullandığı örnek veri: projeler, sprintler ve görevler (ekranlar doğrudan kullanmaz) |
| `lib/providers/` | `AuthProvider` (oturum durumu) |
| `lib/screens/` | Ekranlar |
| `lib/widgets/` | Ortak bileşenler (yükleniyor / hata / boş durum, rozetler) |
| `lib/routes/` | `go_router` yönlendirmesi ve oturum kontrolü |
| `lib/theme/`, `lib/utils/` | Tema, tarih ve story point biçimlendirme |
| `test/` | Sahte servis ve ekran testleri |

## Commit kuralları

Web projesindeki kurallarla aynıdır (bkz. web README):

```
<tür>(haftaN/<kapsam>): <emir kipinde kısa Türkçe açıklama>
```

Türler: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`. Örnek: `feat(hafta3/projelerim): projeleri servisten yükle`. Her commit tek bir iş yapar ve proje o haliyle derlenir.

## Haftalık ilerleme

- **Hafta 1:** Proje iskeleti, tema, yönlendirme ve model sınıfları.
- **Hafta 2:** Giriş ve kayıt ekranları, JWT ile gerçek giriş, oturumun saklanması ve süre dolunca otomatik çıkış.
- **Hafta 3:** Proje ekranları örnek veriyle: Projelerim (arama, yenileme), proje detayı (aktif sprint kartı), sprint listesi (durum filtresi) ve 4. hafta için API servis katmanı. Ekranlar servis arayüzleri üzerinden çalışır; yükleniyor, hata ve boş durumları ortak bileşenlerle gösterilir.
- **Hafta 4:** Ekranların gerçek API'ye bağlanması. Örnek veri web'deki demo verisiyle eşitlendi (görevler eklendi, tarihler bugüne göre hesaplanıyor); README'ye gerçek API ile çalıştırma ve demo hesapları eklendi.
