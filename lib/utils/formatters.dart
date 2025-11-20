import 'package:intl/intl.dart';

class Formatters {
  /// Format angka ke format mata uang Rupiah
  /// Contoh: 50000 → "Rp 50.000"
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format ISO DateTime string ke format tanggal dan waktu lengkap
  /// Contoh: "2024-01-15T14:30:00" → "15 Jan 2024, 14:30"
  static String formatScheduleTime(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// Format ISO DateTime string ke format waktu saja
  /// Contoh: "2024-01-15T14:30:00" → "14:30"
  static String formatTimeOnly(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// Format ISO DateTime string ke format tanggal lengkap
  /// Contoh: "2024-01-15T14:30:00" → "Senin, 15 Jan 2024"
  static String formatDateFull(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('EEEE, dd MMM yyyy').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// Format ISO DateTime string ke format tanggal dan waktu lengkap dengan hari
  /// Contoh: "2024-01-15T14:30:00" → "Senin, 15 Jan 2024 - 14:30"
  static String formatDateTimeFull(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('EEEE, dd MMM yyyy - HH:mm').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// Format ISO DateTime string ke format tanggal saja (yyyy-MM-dd)
  /// Contoh: "2024-01-15T14:30:00" → "2024-01-15"
  static String formatDateKey(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// Format DateTime ke string dengan format custom
  /// Contoh: formatDateTime(DateTime.now(), 'dd/MM/yyyy HH:mm')
  static String formatDateTime(DateTime dateTime, String pattern) {
    try {
      return DateFormat(pattern).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }
}
