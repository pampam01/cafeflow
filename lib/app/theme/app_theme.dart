import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette (Warm Cafe Modern SaaS)
  static const Color primaryCoffee = Color(0xFF5D4037); // Rich Warm Coffee / Espresso
  static const Color primaryCoffeeDark = Color(0xFFD7CCC8);
  static const Color secondaryAmber = Color(0xFFD97706); // Warm Golden Bronze Accent
  static const Color tertiarySage = Color(0xFF4A6B5D); // Muted Sage Green
  static const Color backgroundLight = Color(0xFFFAF9F6); // Off-white warm cream
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF141110); // Deep Charcoal Slate
  static const Color surfaceDark = Color(0xFF1E1A18);
  static const Color borderLight = Color(0xFFE6E1DC);
  static const Color borderDark = Color(0xFF332D29);

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCoffee,
        brightness: Brightness.light,
        primary: primaryCoffee,
        onPrimary: Colors.white,
        secondary: secondaryAmber,
        tertiary: tertiarySage,
        surface: surfaceLight,
        outline: borderLight,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9F8F6),
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: const Color(0xFF2C221E),
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: const Color(0xFF2C221E),
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: const Color(0xFF4A403A),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF2C221E)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2C221E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primaryCoffee),
        unselectedIconTheme: IconThemeData(color: Color(0xFF8D837C)),
        selectedLabelTextStyle: TextStyle(
          color: primaryCoffee,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Color(0xFF8D837C),
          fontSize: 13,
        ),
        indicatorColor: Color(0xFFEFEBE9),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEFEBE9),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryCoffee, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF8D837C), fontSize: 12);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCoffee, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryCoffee,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCoffee,
          side: const BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCoffee,
        brightness: Brightness.dark,
        primary: primaryCoffeeDark,
        onPrimary: const Color(0xFF2C221E),
        secondary: secondaryAmber,
        tertiary: tertiarySage,
        surface: surfaceDark,
        outline: borderDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: const Color(0xFFECE6E2),
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: const Color(0xFFECE6E2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFFECE6E2)),
        titleTextStyle: TextStyle(
          color: Color(0xFFECE6E2),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
