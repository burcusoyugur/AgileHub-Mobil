import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../services/api_exception.dart';

/// Veri yüklenirken ekranın ortasında gösterilir.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Hatadan ekranda gösterilecek Türkçe mesajı çıkarır.
///
/// [ApiException] zaten Türkçe mesaj taşır; başka bir hata (programlama hatası
/// vb.) ise kullanıcıya teknik ayrıntı yerine [fallback] gösterilir.
String errorMessage(
  Object error, {
  String fallback = 'Beklenmeyen bir hata oluştu',
}) {
  return error is ApiException ? error.message : fallback;
}

/// Ekranda veri varken yenileme başarısız olursa kullanılır: liste ekranda
/// kalır, hata altta kısa bir bildirimle (SnackBar) gösterilir.
///
/// 401'de bildirim gösterilmez; oturum düşmesini `main.dart` tek bir
/// bildirimle karşılar ve giriş ekranına yönlendirir.
void showErrorSnackBar(BuildContext context, Object error, {String? fallback}) {
  if (error is ApiException && error.isUnauthorized) return;

  final message = fallback == null
      ? errorMessage(error)
      : errorMessage(error, fallback: fallback);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Yükleme başarısız olduğunda hata mesajı ve "Tekrar dene" butonu.
///
/// [error] verilirse simge hatanın türüne göre seçilir: yetki yoksa (403)
/// kilit, sunucuya ulaşılamadıysa bulut. Geliştirme sırasında bağlantı
/// hatasında uygulamanın hangi adrese bağlanmaya çalıştığı da yazılır.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Object? error;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.error,
  });

  /// Mesajı hatadan kendisi çıkarır: `ErrorView.fromError(snapshot.error!, ...)`.
  ErrorView.fromError(
    Object this.error, {
    super.key,
    String fallback = 'Beklenmeyen bir hata oluştu',
    this.onRetry,
  }) : message = errorMessage(error, fallback: fallback);

  ApiException? get _apiError {
    final e = error;
    return e is ApiException ? e : null;
  }

  IconData get _icon {
    final apiError = _apiError;
    if (apiError == null) return Icons.error_outline;
    if (apiError.isForbidden) return Icons.lock_outline;
    if (apiError.isConnectionError) return Icons.cloud_off_outlined;
    return Icons.error_outline;
  }

  /// Yalnızca debug derlemede ve bağlantı hatasında: "Adres: http://10.0.2.2:5203".
  String? get _debugAddress {
    if (!kDebugMode || !(_apiError?.isConnectionError ?? false)) return null;
    try {
      return 'Adres: ${ApiConfig.baseUrl}';
    } catch (_) {
      // Web'de Platform bilgisi okunamaz; adres gösterilmeden devam edilir.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final debugAddress = _debugAddress;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (debugAddress != null) ...[
              const SizedBox(height: 4),
              Text(
                debugAddress,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Liste boş olduğunda gösterilir.
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
