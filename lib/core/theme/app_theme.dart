import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Palette ────────────────────────────────────────────────
  static const Color primaryGreen  = Color(0xFF2D6A4F); // deep forest green
  static const Color primaryLight  = Color(0xFF52B788); // mid green
  static const Color primaryDark   = Color(0xFF1B4332); // darkest green
  static const Color primarySurface = Color(0xFFD8F3DC); // soft mint tint

  static const Color secondary     = Color(0xFFE9C46A); // warm amber
  static const Color secondaryLight = Color(0xFFF4D35E);
  static const Color secondaryDark  = Color(0xFFBB8A23);

  static const Color accent        = Color(0xFF40916C); // teal-green
  static const Color accentLight   = Color(0xFF74C69D);

  static const Color error         = Color(0xFFD62828);
  static const Color warning       = Color(0xFFF4A261);
  static const Color success       = Color(0xFF52B788);
  static const Color info          = Color(0xFF457B9D);

  // ─── Backgrounds & Surfaces ───────────────────────────────────────
  static const Color backgroundLight = Color(0xFFE6EFE8); // soft sage
  static const Color backgroundDark  = Color(0xFF0F1F17); // deep dark green

  static const Color surfaceLight  = Color(0xFFEFF5F1);
  static const Color surfaceDark   = Color(0xFF1A2E22);
  static const Color surfaceCard   = Color(0xFFE7F1EA); // muted card green

  // ─── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1B2A1E);
  static const Color textSecondary = Color(0xFF4A6550);
  static const Color textHint      = Color(0xFF9BBCA3);
  static const Color textOnDark    = Color(0xFFE8F5E9);
  
  // Light Theme
  // ─── Light Theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: primarySurface,
      onPrimaryContainer: primaryDark,
      secondary: secondary,
      secondaryContainer: Color(0xFFFFF3CD),
      surface: surfaceLight,
      surfaceContainerHighest: backgroundLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge:  GoogleFonts.inter(fontSize: 56, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -1.5),
      displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
      displaySmall:  GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w600, color: textPrimary),
      headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium:GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge:    GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.15),
      titleSmall:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.1),
      bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.1),
      labelMedium:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.5),
      labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textHint, letterSpacing: 0.5),
    ),

    scaffoldBackgroundColor: backgroundLight,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      toolbarHeight: 64,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4E6DA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4E6DA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: textHint, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
    ),

    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EFE8)),
      ),
      margin: EdgeInsets.zero,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: primarySurface,
      selectedColor: primaryGreen,
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFEAF1EB),
      thickness: 1,
      space: 1,
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),

    iconTheme: const IconThemeData(color: textSecondary, size: 22),
    primaryIconTheme: const IconThemeData(color: primaryGreen),
  );

  // ─── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: Color(0xFF1A3D2B),
      secondary: secondary,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textOnDark,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF2A4535)),
      ),
    ),
  );

  // ─── Convenience helpers ──────────────────────────────────────────

  /// Standard page padding responsive to screen width
  static EdgeInsets pagePadding(double screenWidth) {
    if (screenWidth >= 1400) return const EdgeInsets.symmetric(horizontal: 80, vertical: 32);
    if (screenWidth >= 1200) return const EdgeInsets.symmetric(horizontal: 48, vertical: 28);
    if (screenWidth >= 900)  return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  /// Max content width for centered website layouts
  static double contentMaxWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1280;
    if (screenWidth >= 1200) return 1100;
    if (screenWidth >= 900)  return 860;
    return screenWidth;
  }
}