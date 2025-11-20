class Validators {
  Validators._(); // Private constructor

  /// Validasi email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    // Regex untuk validasi email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi password (minimal 6 karakter)
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi konfirmasi password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak sama';
    }
    return null;
  }

  /// Validasi nomor telepon Indonesia
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    // Hapus spasi dan karakter non-digit
    final cleanNumber = value.replaceAll(RegExp(r'\D'), '');

    // Minimal 10 digit, maksimal 13 digit
    if (cleanNumber.length < 10 || cleanNumber.length > 13) {
      return 'Nomor telepon tidak valid (10-13 digit)';
    }

    // Harus dimulai dengan 0 atau 62
    if (!cleanNumber.startsWith('0') && !cleanNumber.startsWith('62')) {
      return 'Nomor telepon harus dimulai dengan 0 atau 62';
    }

    return null;
  }

  /// Validasi username (alfanumerik, 3-20 karakter)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username wajib diisi';
    }
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    if (value.length > 20) {
      return 'Username maksimal 20 karakter';
    }
    // Hanya alfanumerik dan underscore
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username hanya boleh huruf, angka, dan underscore';
    }
    return null;
  }

  /// Validasi nama lengkap
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    return null;
  }

  /// Validasi field wajib diisi (generic)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validasi angka positif
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName harus berupa angka positif';
    }
    return null;
  }

  /// Validasi nomor kartu (16 digit)
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor kartu wajib diisi';
    }
    if (value.length != 16) {
      return 'Nomor kartu harus berisi 16 digit';
    }
    // Pastikan semua karakter adalah digit
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Nomor kartu hanya boleh berisi angka';
    }
    return null;
  }
}
