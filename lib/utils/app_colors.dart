import 'package:flutter/material.dart';

/// Konstanta warna yang digunakan di seluruh aplikasi
class AppColors {
  AppColors._(); // Private constructor untuk mencegah instantiation

  /// Warna primer aplikasi - Dark Slate (Navy Blue)
  static const Color primary = Color(0xFF0F172A);

  /// Warna primer dengan opacity
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);

  /// Warna untuk background light
  static const Color backgroundLight = Colors.white;

  /// Warna untuk teks gelap
  static const Color textDark = Colors.black87;

  /// Warna untuk teks medium
  static const Color textMedium = Colors.black54;

  /// Warna untuk teks light/hint
  static const Color textLight = Colors.grey;

  /// Warna untuk error/danger
  static const Color error = Colors.red;

  /// Warna untuk success
  static const Color success = Colors.green;

  /// Warna untuk warning
  static const Color warning = Colors.orange;

  /// Warna untuk border/divider
  static Color border = Colors.grey.shade300;

  /// Warna untuk background secondary
  static Color backgroundSecondary = Colors.grey.shade100;
}
