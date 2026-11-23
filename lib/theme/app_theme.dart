import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _secondaryColor = Color(0xFF7C3AED);
  static const Color _errorColor = Color(0xFFDC2626);

  // Durum renkleri koyu zeminde okunacak açık tonlar (web'deki rozetlerle aynı).
  static const Color _todoColor = Color(0xFF94A0C2);
  static const Color _inProgressColor = Color(0xFF8FB0FF);
  static const Color _testingColor = Color(0xFFFFC062);
  static const Color _doneColor = Color(0xFF4FE0C3);

  // Koyu tema paleti: web'deki wwwroot/css/tema.css ile aynı renkler.
  static const Color _zemin = Color(0xFF0B1022);
  static const Color _ust = Color(0xFF0E1530);
  static const Color _kart = Color(0xFF121A33);
  static const Color _kartAcik = Color(0xFF18213F);
  static const Color _girdi = Color(0xFF0F1630);
  static const Color _yazi = Color(0xFFE8ECF8);
  static const Color _soluk = Color(0xFF94A0C2);
  static const Color _mavi = Color(0xFF4F7CFF);
  static const Color _acikMavi = Color(0xFF8FB0FF);
  static const Color _mor = Color(0xFF8B5CF6);
  static const Color _yesil = Color(0xFF22C3A6);
  static const Color _kirmizi = Color(0xFFF05D6C);
  static const Color _cizgi = Color(0x2494A3D6); // %14 opak açık mavi-gri
  static const Color _cizgiBelirgin = Color(0x5994A3D6); // %35

  static Color get todoColor => _todoColor;
  static Color get inProgressColor => _inProgressColor;
  static Color get testingColor => _testingColor;
  static Color get doneColor => _doneColor;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// Uygulamanın kullandığı koyu tema (bkz. main.dart, themeMode: ThemeMode.dark).
  /// Renkler web'deki koyu temayla aynıdır; ekranlar renkleri buradan alır.
  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _mavi,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF233A8F),
      onPrimaryContainer: Color(0xFFDBE4FF),
      secondary: _mor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF3B2A8A),
      onSecondaryContainer: Color(0xFFE6DCFF),
      tertiary: _yesil,
      onTertiary: Color(0xFF00201A),
      error: _kirmizi,
      onError: Colors.white,
      errorContainer: Color(0xFF4A1D28),
      onErrorContainer: Color(0xFFFFB3BB),
      surface: _zemin,
      onSurface: _yazi,
      onSurfaceVariant: _soluk,
      surfaceContainerLowest: _zemin,
      surfaceContainerLow: _ust,
      surfaceContainer: _kart,
      surfaceContainerHigh: _kartAcik,
      surfaceContainerHighest: Color(0xFF1E2850),
      outline: _cizgiBelirgin,
      outlineVariant: _cizgi,
      inverseSurface: _yazi,
      onInverseSurface: _zemin,
      inversePrimary: Color(0xFF2563EB),
      surfaceTint: Colors.transparent,
    );

    final yuvarlak12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _zemin,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: _ust,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: _cizgi)),
      ),
      cardTheme: CardThemeData(
        color: _kart,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _cizgi),
        ),
      ),
      listTileTheme: const ListTileThemeData(iconColor: _soluk),
      dividerTheme: const DividerThemeData(color: _cizgi),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _girdi,
        hintStyle: const TextStyle(color: Color(0xFF6F7BA0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x4094A3D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _mavi, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kirmizi),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _mavi,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: yuvarlak12,
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _mavi,
          foregroundColor: Colors.white,
          shape: yuvarlak12,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _acikMavi,
          side: const BorderSide(color: Color(0x994F7CFF)),
          minimumSize: const Size.fromHeight(48),
          shape: yuvarlak12,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _acikMavi),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _mavi,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _kartAcik,
        selectedColor: const Color(0x404F7CFF),
        side: const BorderSide(color: _cizgi),
        labelStyle: const TextStyle(color: _yazi),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: _mavi,
        labelColor: Colors.white,
        unselectedLabelColor: _soluk,
        dividerColor: _cizgi,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _mavi,
        linearTrackColor: Color(0x2E94A3D6),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _kartAcik,
        contentTextStyle: TextStyle(color: _yazi),
        actionTextColor: _acikMavi,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: _kart),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _ust,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
