import 'package:flutter/material.dart';
import 'package:utspam_b_0023_film/utils/app_colors.dart';

class UIHelpers {
  UIHelpers._(); // Private constructor

  /// Menampilkan loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  /// Menutup loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  /// Menampilkan snackbar dengan pesan
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  /// Menampilkan snackbar error
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.error);
  }

  /// Menampilkan snackbar success
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.success);
  }

  /// Menampilkan dialog konfirmasi
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: TextStyle(color: confirmColor ?? AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Padding standar untuk screen
  static const EdgeInsets screenPadding = EdgeInsets.all(24);

  /// Padding kecil
  static const EdgeInsets smallPadding = EdgeInsets.all(8);

  /// Padding medium
  static const EdgeInsets mediumPadding = EdgeInsets.all(16);

  /// Border radius standar
  static BorderRadius get defaultBorderRadius => BorderRadius.circular(12);

  /// Border radius kecil
  static BorderRadius get smallBorderRadius => BorderRadius.circular(8);

  /// Border radius besar
  static BorderRadius get largeBorderRadius => BorderRadius.circular(16);

  /// Box shadow standar
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.grey.shade200,
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];
}
