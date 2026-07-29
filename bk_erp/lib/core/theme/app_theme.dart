import 'package:flutter/material.dart';

class AppColors {
  // ── Book Keeper–inspired palette ────────────────────────────────────────
  // A classic accounting-software palette: teal green accents, royal blue
  // table headers, bright yellow search highlights, and Win32-era gray
  // surfaces. Feels "old but expensive."

  // Primary — Teal Green (matches BK's company-name accent)
  static const Color primary = Color(0xFF008080);       // Classic Teal
  static const Color primaryLight = Color(0xFF26A69A);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color secondary = Color(0xFFF59E0B);     // Amber accent

  // Sidebar (White/Light — Book Keeper uses a light sidebar)
  static const Color sidebarBg = Color(0xFFF5F5F0);     // Warm off-white
  static const Color sidebarSelected = Color(0xFF008080);  // Teal highlight
  static const Color sidebarHover = Color(0xFFE0E0D8);
  static const Color sidebarText = Color(0xFF4A4A4A);
  static const Color sidebarTextActive = Colors.white;
  static const Color sidebarGroupHeader = Color(0xFF333333);

  // Surface & Background (Win32-era grays)
  static const Color background = Color(0xFFE8E8E0);    // Classic form gray
  static const Color surface = Colors.white;
  static const Color surfaceBorder = Color(0xFFBDBDB5);  // Heavier border like BK

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textHint = Color(0xFF999999);

  // Table header — Royal Blue (BK's signature table header)
  static const Color tableHeaderBg = Color(0xFF003399);
  static const Color tableHeaderText = Colors.white;

  // Search field — BK's iconic yellow
  static const Color searchBg = Color(0xFFFFFF00);
  static const Color searchText = Color(0xFF000000);

  // Status
  static const Color success = Color(0xFF228B22);        // Forest green
  static const Color warning = Color(0xFFCC8800);
  static const Color error = Color(0xFFCC0000);
  static const Color info = Color(0xFF336699);

  // Cards (muted, classic)
  static const Color cardGreen = Color(0xFFE8F5E9);
  static const Color cardBlue = Color(0xFFE3EDF7);
  static const Color cardOrange = Color(0xFFFFF8E1);
  static const Color cardRed = Color(0xFFFDE8E8);

  // Toolbar ribbon
  static const Color ribbonBg = Color(0xFFD4D4CC);
  static const Color ribbonBorder = Color(0xFFB0B0A8);

  // Status bar
  static const Color statusBarBg = Color(0xFFE0E0D8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,  // Material 2 for that classic, dense feel
      fontFamily: 'Segoe UI',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),  // Sharp corners — classic
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Segoe UI',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Segoe UI',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Segoe UI',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.tableHeaderText,
          fontSize: 12,
          fontFamily: 'Segoe UI',
        ),
        dataTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontFamily: 'Segoe UI',
        ),
        headingRowHeight: 32,
        dataRowMinHeight: 28,
        dataRowMaxHeight: 36,
        columnSpacing: 24,
        dividerThickness: 1,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 13, color: AppColors.textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
      iconTheme: const IconThemeData(
        size: 18,
        color: AppColors.textSecondary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFE0),  // Classic tooltip yellow
          border: Border.all(color: AppColors.surfaceBorder),
          borderRadius: BorderRadius.circular(2),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFFB0B0A8)),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(0),  // Classic square scrollbar
      ),
    );
  }
}
