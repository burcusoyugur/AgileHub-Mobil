/// Tarihi ekranda gösterilecek biçime çevirir: `02.11.2026`.
String formatDate(DateTime date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year}';
}

/// Sprint gibi tarih aralıkları için: `02.11.2026 – 08.11.2026`.
String formatDateRange(DateTime start, DateTime end) =>
    '${formatDate(start)} – ${formatDate(end)}';

/// Story point ilerlemesi için: `8 / 21 SP`.
String formatStoryPoints(int completed, int total) => '$completed / $total SP';
