import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ─── Backgrounds ──────────────────────────────────────────────
  static const bgPrimary = Color(0xFF0F1117);
  static const bgSurface = Color(0xFF1A1D27);
  static const bgCard    = Color(0xFF1E2235);

  // ─── Accents ──────────────────────────────────────────────────
  static const accentGreen = Color(0xFF00E5A0);
  static const accentBlue  = Color(0xFF3B8AFF);
  static const accentOrange = Color(0xFFFFB347);

  // ─── Text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF0F2FF);
  static const textMuted   = Color(0xFF8B90A8);

  // ─── Status ───────────────────────────────────────────────────
  static const success = Color(0xFF00E5A0);
  static const warning = Color(0xFFFFB347);
  static const error   = Color(0xFFFF5C5C);

  // ─── Tag Backgrounds ──────────────────────────────────────────
  static const tagGreenBg  = Color(0x1F00E5A0); // 12% opacity
  static const tagBlueBg   = Color(0x263B8AFF); // 15% opacity
  static const tagOrangeBg = Color(0x26FFB347); // 15% opacity

  // ─── Borders ──────────────────────────────────────────────────
  static const border = Color(0x12FFFFFF); // 7% white
}