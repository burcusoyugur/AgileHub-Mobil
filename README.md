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

**Demo hesap (sahte mod):** `admin@agilehub.local`, şifre olarak en az 6 karakterlik herhangi bir değer (ör. `demo123`).

## Sahte ve gerçek mod

Mod, `--dart-define` ile seçilir. Ekranlar veriyi her zaman servis arayüzlerinden (`ProjectService`, `SprintService`) alır; hangi servisin kullanılacağı `lib/main.dart`'ta belirlenir.

| Ayar | Varsayılan | Açıklama |
| --- | --- | --- |
| `USE_MOCK_AUTH` | `true` | `false` olunca giriş ve kayıt gerçek API'ye gider (`/api/auth/...`) |
| `USE_MOCK_DATA` | `true` | `false` olunca projeler ve sprintler gerçek API'den gelir (`/api/projeler`, `/api/sprintler`) |
| `API_PORT` | `5203` | Web API'nin çalıştığı port |

> **Not:** `USE_MOCK_DATA` ayarı API servis katmanıyla (`hafta3/api-servis`) gelir. O dal birleşene kadar bu ayar yok sayılır; projeler ve sprintler her zaman örnek veriden gelir.

Gerçek API ile çalıştırmak için önce web projesini kendi README'sindeki adımlarla ayağa kaldırın (`dotnet run --launch-profile http`, adres `http://localhost:5203`), sonra:

```
flutter run --dart-define=USE_MOCK_AUTH=false --dart-define=USE_MOCK_DATA=false
```

- Android emülatöründe bilgisayarın `localhost`'u `10.0.2.2` adresidir; uygulama bunu kendisi seçer.
- Web API farklı bir portta çalışıyorsa `--dart-define=API_PORT=<port>` ekleyin.
- Gerçek modda giriş için web'deki hesaplar kullanılır (ör. geliştirme ortamında `test@agilehub.local`).

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
| `lib/data/` | Sahte servislerin kullandığı örnek veri (ekranlar doğrudan kullanmaz) |
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
