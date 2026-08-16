import 'package:flutter/material.dart';

/// Custom color scheme with a royal ethereal aesthetic.
///
/// Light mode: Soft cream, pearlescent whites, warm amber gold, and amethyst accents.
/// Dark mode: Deep midnight violet, dark obsidian, glowing royal gold, and luminous rose.
class AppColorScheme {
  AppColorScheme._();

  // ─── Brand Colors ────────────────────────────────────────────────────
  static const Color primaryGold = Color(0xFFF5C34A);
  static const Color royalPurple = Color(0xFF9D50BB);
  static const Color etherealPink = Color(0xFFEDB1FF);
  static const Color midnightViolet = Color(0xFF130D1B);
  static const Color deepObsidian = Color(0xFF1C1328);

  // ─── Gradients ───────────────────────────────────────────────────────
  static const LinearGradient royalBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF130D1B),
      Color(0xFF1C1328),
      Color(0xFF120B1A),
    ],
  );

  static const LinearGradient crownGoldGradient = LinearGradient(
    colors: [
      Color(0xFFFFDF79),
      Color(0xFFF5C34A),
      Color(0xFFD4920B),
    ],
  );

  static const LinearGradient purpleAmethystGradient = LinearGradient(
    colors: [
      Color(0xFFB06AB3),
      Color(0xFF9D50BB),
      Color(0xFF6E48AA),
    ],
  );

  static const LinearGradient emeraldHealthGradient = LinearGradient(
    colors: [
      Color(0xFF56CCF2),
      Color(0xFF4CAF76),
    ],
  );

  static const LinearGradient sunsetRoseGradient = LinearGradient(
    colors: [
      Color(0xFFFF7E67),
      Color(0xFFE91E63),
    ],
  );

  // ─── Category Colors ─────────────────────────────────────────────────
  static const Color categoryWork = Color(0xFF5B7FD6);
  static const Color categoryHealth = Color(0xFF4CAF76);
  static const Color categoryPersonal = Color(0xFFE8915A);

  // ─── Priority Colors ─────────────────────────────────────────────────
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityMedium = Color(0xFFF5A623);
  static const Color priorityLow = Color(0xFF4CAF76);

  // ─── Light Scheme ────────────────────────────────────────────────────
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: primaryGold,
        brightness: Brightness.light,
        primary: const Color(0xFFB07A08),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFFF0D4),
        onPrimaryContainer: const Color(0xFF3D2A00),
        secondary: const Color(0xFF9D50BB),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF4E5FF),
        onSecondaryContainer: const Color(0xFF36004C),
        tertiary: const Color(0xFF4CAF76),
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFD7F8E3),
        onTertiaryContainer: const Color(0xFF00391A),
        surface: const Color(0xFFFBF8F5),
        onSurface: const Color(0xFF1D1B16),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF6F0E8),
        surfaceContainer: const Color(0xFFEEE6DC),
        surfaceContainerHigh: const Color(0xFFE6DCCE),
        surfaceContainerHighest: const Color(0xFFDDD2C2),
        onSurfaceVariant: const Color(0xFF4D4639),
        outline: const Color(0xFF7E7668),
        outlineVariant: const Color(0xFFCFC5B4),
        error: const Color(0xFFBA1A1A),
        onError: Colors.white,
      );

  // ─── Dark Scheme ─────────────────────────────────────────────────────
  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: primaryGold,
        brightness: Brightness.dark,
        primary: primaryGold,
        onPrimary: const Color(0xFF3D2A00),
        primaryContainer: const Color(0xFF5A4000),
        onPrimaryContainer: const Color(0xFFFFF0D4),
        secondary: etherealPink,
        onSecondary: const Color(0xFF52006A),
        secondaryContainer: const Color(0xFF6E48AA),
        onSecondaryContainer: const Color(0xFFFBE8FF),
        tertiary: const Color(0xFF7FE7A9),
        onTertiary: const Color(0xFF00391A),
        tertiaryContainer: const Color(0xFF2E6342),
        onTertiaryContainer: const Color(0xFFD7F8E3),
        surface: midnightViolet,
        onSurface: const Color(0xFFF5EFF8),
        surfaceContainerLowest: const Color(0xFF0D0813),
        surfaceContainerLow: const Color(0xFF181023),
        surfaceContainer: const Color(0xFF1E152C),
        surfaceContainerHigh: const Color(0xFF281C3B),
        surfaceContainerHighest: const Color(0xFF33244B),
        onSurfaceVariant: const Color(0xFFD1C2D2),
        outline: const Color(0xFF9A8C9B),
        outlineVariant: const Color(0xFF4A3E54),
        error: const Color(0xFFFF8A80),
        onError: const Color(0xFF690005),
      );
}
