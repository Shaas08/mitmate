import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mitmate colours, taken from the approved Sprint 1 design.
class MC {
  static const bg = Color(0xFFF4EFE6);
  static const ink = Color(0xFF1B2B26);
  static const mute = Color(0xFF55645E);
  static const line = Color(0xFFDCD4C6);
  static const pri = Color(0xFF1F6B57);
  static const priDeep = Color(0xFF164F40);
  static const priSoft = Color(0xFFDDEEE7);
  static const coral = Color(0xFFD9603B);
  static const yes = Color(0xFF23844A);
  static const no = Color(0xFFC73A3A);
  static const warn = Color(0xFF9B2C2C);
}

TextStyle serif({double size = 24, FontWeight weight = FontWeight.w400, Color color = MC.ink, double height = 1.3}) =>
    GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color, height: height);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: MC.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: MC.pri).copyWith(
      primary: MC.pri,
      secondary: MC.coral,
      error: MC.warn,
      surface: MC.bg,
    ),
  );
  final text = GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: MC.ink, displayColor: MC.ink);
  return base.copyWith(
    textTheme: text,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: MC.line, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: MC.line, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: MC.pri, width: 2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: MC.pri,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: MC.pri,
        side: const BorderSide(color: MC.pri, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
