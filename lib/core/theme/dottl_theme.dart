import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DottrTheme {
  // Neo-brutalist color tokens
  static const _black = Color(0xFF1A1A1A);
  static const _white = Color(0xFFFAFAFA);
  static const _cream = Color(0xFFF5F0EB);
  static const _yellow = Color(0xFFFFE566);
  static const _blue = Color(0xFF4D9DE0);
  static const _pink = Color(0xFFFF6B9D);
  static const _green = Color(0xFF7BC67E);
  static const _red = Color(0xFFE85D75);
  static const _gray = Color(0xFF6B6B6B);
  static const _lightGray = Color(0xFFE0E0E0);
  static const _darkGray = Color(0xFF2D2D2D);
  static const _darkSurface = Color(0xFF1E1E1E);
  static const _darkCard = Color(0xFF2A2A2A);

  static const double borderWidth = 2.5;
  static const double cardRadius = 4.0;
  static const double shadowOffset = 4.0;

  static TextTheme _textTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light ? _black : _white;
    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor.withAlpha(180),
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _cream,
      textTheme: _textTheme(Brightness.light),
      colorScheme: const ColorScheme.light(
        primary: _black,
        onPrimary: _white,
        secondary: _yellow,
        onSecondary: _black,
        tertiary: _blue,
        error: _red,
        onError: _white,
        surface: _white,
        onSurface: _black,
        outline: _black,
        outlineVariant: _lightGray,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _cream,
        foregroundColor: _black,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _black,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _white,
        selectedItemColor: _black,
        unselectedItemColor: _gray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellow,
        foregroundColor: _black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
          side: BorderSide(color: _black, width: borderWidth),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _white,
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: _black,
        ),
        side: const BorderSide(color: _black, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _black, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _black, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _blue, width: borderWidth),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightGray,
        thickness: 1,
      ),
      extensions: const [
        DottrColors(
          accent: _yellow,
          accentAlt: _blue,
          pink: _pink,
          green: _green,
          shadow: _black,
          muted: _gray,
        ),
      ],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkSurface,
      textTheme: _textTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: _white,
        onPrimary: _black,
        secondary: _yellow,
        onSecondary: _black,
        tertiary: _blue,
        error: _red,
        onError: _white,
        surface: _darkCard,
        onSurface: _white,
        outline: _white,
        outlineVariant: _darkGray,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _white,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkCard,
        selectedItemColor: _yellow,
        unselectedItemColor: _gray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellow,
        foregroundColor: _black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
          side: BorderSide(color: _white, width: borderWidth),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkCard,
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: _white,
        ),
        side: const BorderSide(color: _white, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _white, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _white, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _blue, width: borderWidth),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkGray,
        thickness: 1,
      ),
      extensions: const [
        DottrColors(
          accent: _yellow,
          accentAlt: _blue,
          pink: _pink,
          green: _green,
          shadow: _black,
          muted: _gray,
        ),
      ],
    );
  }
}

class DottrColors extends ThemeExtension<DottrColors> {
  final Color accent;
  final Color accentAlt;
  final Color pink;
  final Color green;
  final Color shadow;
  final Color muted;

  const DottrColors({
    required this.accent,
    required this.accentAlt,
    required this.pink,
    required this.green,
    required this.shadow,
    required this.muted,
  });

  @override
  DottrColors copyWith({
    Color? accent,
    Color? accentAlt,
    Color? pink,
    Color? green,
    Color? shadow,
    Color? muted,
  }) {
    return DottrColors(
      accent: accent ?? this.accent,
      accentAlt: accentAlt ?? this.accentAlt,
      pink: pink ?? this.pink,
      green: green ?? this.green,
      shadow: shadow ?? this.shadow,
      muted: muted ?? this.muted,
    );
  }

  @override
  DottrColors lerp(ThemeExtension<DottrColors>? other, double t) {
    if (other is! DottrColors) return this;
    return DottrColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      green: Color.lerp(green, other.green, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}
