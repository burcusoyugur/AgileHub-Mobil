import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agilehub_mobil/services/api_exception.dart';
import 'package:agilehub_mobil/widgets/state_views.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ErrorView', () {
    testWidgets('403: kilit simgesi ve mesaj', (tester) async {
      await tester.pumpWidget(
        _app(
          ErrorView.fromError(
            const ApiException('Bu kayda erişim yetkin yok', statusCode: 403),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Bu kayda erişim yetkin yok'), findsOneWidget);
    });

    testWidgets('bağlantı hatası: bulut simgesi ve sunucu adresi (debug)',
        (tester) async {
      await tester.pumpWidget(
        _app(ErrorView.fromError(const ApiException('Sunucuya ulaşılamadı'))),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.text('Sunucuya ulaşılamadı'), findsOneWidget);
      // Testler debug modda çalışır; bağlanılmaya çalışılan adres gösterilir.
      expect(find.textContaining('Adres: http://'), findsOneWidget);
    });

    testWidgets('diğer hatalar: genel hata simgesi, adres yok', (tester) async {
      await tester.pumpWidget(
        _app(
          ErrorView.fromError(
            const ApiException('Kayıt bulunamadı', statusCode: 404),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Adres:'), findsNothing);
    });

    testWidgets('ApiException olmayan hatada yedek mesaj gösterilir',
        (tester) async {
      await tester.pumpWidget(
        _app(
          ErrorView.fromError(
            StateError('iç hata'),
            fallback: 'Projeler yüklenemedi',
          ),
        ),
      );

      expect(find.text('Projeler yüklenemedi'), findsOneWidget);
      expect(find.textContaining('iç hata'), findsNothing);
    });

    testWidgets('eski kullanım (yalnızca mesaj) çalışmaya devam eder',
        (tester) async {
      var tiklandi = false;
      await tester.pumpWidget(
        _app(ErrorView(message: 'Hata', onRetry: () => tiklandi = true)),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      await tester.tap(find.text('Tekrar dene'));
      expect(tiklandi, isTrue);
    });
  });

  group('showErrorSnackBar', () {
    Future<void> goster(WidgetTester tester, Object error) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showErrorSnackBar(context, error),
              child: const Text('dene'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('dene'));
      await tester.pump();
    }

    testWidgets('API hatasının mesajını SnackBar ile gösterir', (tester) async {
      await goster(tester, const ApiException('Sunucuya ulaşılamadı'));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sunucuya ulaşılamadı'), findsOneWidget);
    });

    testWidgets('401de göstermez (oturum düşmesi ayrıca bildirilir)',
        (tester) async {
      await goster(
        tester,
        const ApiException('Oturumun süresi doldu', statusCode: 401),
      );

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('bilinmeyen hatada teknik ayrıntı göstermez', (tester) async {
      await goster(tester, Exception('NullPointer'));

      expect(find.text('Beklenmeyen bir hata oluştu'), findsOneWidget);
    });
  });
}
