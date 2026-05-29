import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF22C55E);
  static const Color primaryDark   = Color(0xFF16A34A);
  static const Color primaryLight  = Color(0xFFECFDF5);
  static const Color primaryFade   = Color(0xFFDCFCE7);
  static const Color success       = Color(0xFF22C55E);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFEF4444);
  static const Color info          = Color(0xFF3B82F6);
  static const Color orange        = Color(0xFFF97316);
  static const Color orangeLight   = Color(0xFFFFF7ED);
  static const Color blue          = Color(0xFF3B82F6);
  static const Color blueLight     = Color(0xFFEFF6FF);
  static const Color navActive     = Color(0xFF22C55E);

  // ── Light (static, used where context unavailable) ─────────────────────────
  static const Color background    = Color(0xFFF8FAFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceAlt    = Color(0xFFF1F5F9);
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted     = Color(0xFF94A3B8);
  static const Color border        = Color(0xFFE2E8F0);
  static const Color navInactive   = Color(0xFF94A3B8);
  static const Color shadow        = Color(0x0F0F172A);

  // ── Dark ───────────────────────────────────────────────────────────────────
  static const Color _bgDark       = Color(0xFF0F172A);
  static const Color _surfDark     = Color(0xFF1E293B);
  static const Color _surfAltDark  = Color(0xFF334155);
  static const Color _txtDark      = Color(0xFFF1F5F9);
  static const Color _txtSecDark   = Color(0xFF94A3B8);
  static const Color _txtMutDark   = Color(0xFF64748B);
  static const Color _bordDark     = Color(0xFF334155);
  static const Color _navInDark    = Color(0xFF64748B);
  static const Color _shadDark     = Color(0x3F000000);
  static const Color _orgLtDark    = Color(0xFF431407);
  static const Color _bluLtDark    = Color(0xFF172554);
  static const Color _primLtDark   = Color(0xFF052E16);
  static const Color _ornLtDark    = Color(0xFF431407);

  // ── Context-aware helpers ──────────────────────────────────────────────────
  static bool _d(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color bg(BuildContext c)        => _d(c) ? _bgDark      : background;
  static Color surf(BuildContext c)      => _d(c) ? _surfDark     : surface;
  static Color surfAlt(BuildContext c)   => _d(c) ? _surfAltDark  : surfaceAlt;
  static Color txt(BuildContext c)       => _d(c) ? _txtDark      : textPrimary;
  static Color txtSec(BuildContext c)    => _d(c) ? _txtSecDark   : textSecondary;
  static Color txtMuted(BuildContext c)  => _d(c) ? _txtMutDark   : textMuted;
  static Color bord(BuildContext c)      => _d(c) ? _bordDark     : border;
  static Color navIn(BuildContext c)     => _d(c) ? _navInDark    : navInactive;
  static Color shad(BuildContext c)      => _d(c) ? _shadDark     : shadow;
  static Color primLight(BuildContext c) => _d(c) ? _primLtDark   : primaryLight;
  static Color orgLight(BuildContext c)  => _d(c) ? _orgLtDark    : orangeLight;
  static Color blLight(BuildContext c)   => _d(c) ? _bluLtDark    : blueLight;
}
