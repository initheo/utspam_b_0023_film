import 'package:utspam_b_0023_film/data/db/db_helper.dart';

class MtixDao {
  final _dbHelper = DBHelper();

  // ==================== USER OPERATIONS ====================

  /// Insert user barum
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await _dbHelper.database;
    return await db.insert(DBHelper.tableUser, user);
  }

  /// Get user by username dan password (untuk login)
  Future<Map<String, dynamic>?> getUserByCredentials(
    String username,
    String password,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableUser,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user by email atau username dan password (untuk login dengan email/username)
  Future<Map<String, dynamic>?> getUserByEmailOrUsernameAndPassword(
    String emailOrUsername,
    String password,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableUser,
      where: '(email = ? OR username = ?) AND password = ?',
      whereArgs: [emailOrUsername, emailOrUsername, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableUser,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user by username (untuk validasi duplikat)
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableUser,
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user by email (untuk validasi duplikat)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableUser,
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user by username dan email (untuk verifikasi lupa password)
  Future<Map<String, dynamic>?> getUserByUsernameAndEmail(
    String username,
    String email,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableUser,
      where: 'username = ? AND email = ?',
      whereArgs: [username, email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Update user
  Future<int> updateUser(int userId, Map<String, dynamic> user) async {
    final db = await _dbHelper.database;
    return await db.update(
      DBHelper.tableUser,
      user,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Update password user (untuk ganti password / reset password)
  Future<int> updateUserPassword(int userId, String newPassword) async {
    final db = await _dbHelper.database;
    return await db.update(
      DBHelper.tableUser,
      {'password': newPassword},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== FILM OPERATIONS ====================

  /// Get semua film
  Future<List<Map<String, dynamic>>> getAllFilms() async {
    final db = await _dbHelper.database;
    final result = await db.query(DBHelper.tableFilm);

    return result;
  }

  /// Get film by ID
  Future<Map<String, dynamic>?> getFilmById(int filmId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableFilm,
      where: 'film_id = ?',
      whereArgs: [filmId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get film by genre
  Future<List<Map<String, dynamic>>> getFilmsByGenre(String genre) async {
    final db = await _dbHelper.database;
    return await db.query(
      DBHelper.tableFilm,
      where: 'genre_film LIKE ?',
      whereArgs: ['%$genre%'],
    );
  }

  /// Search film by title
  Future<List<Map<String, dynamic>>> searchFilms(String keyword) async {
    final db = await _dbHelper.database;
    return await db.query(
      DBHelper.tableFilm,
      where: 'judul_film LIKE ?',
      whereArgs: ['%$keyword%'],
    );
  }

  // ==================== JADWAL OPERATIONS ====================

  /// Get jadwal by film ID
  Future<List<Map<String, dynamic>>> getJadwalByFilmId(int filmId) async {
    final db = await _dbHelper.database;
    return await db.query(
      DBHelper.tableJadwal,
      where: 'film_id = ?',
      whereArgs: [filmId],
    );
  }

  /// Get jadwal by ID
  Future<Map<String, dynamic>?> getJadwalById(int jadwalId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableJadwal,
      where: 'jadwal_id = ?',
      whereArgs: [jadwalId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get jadwal dengan detail film (JOIN)
  Future<List<Map<String, dynamic>>> getJadwalWithFilmDetails(
    int filmId,
  ) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT 
        j.*,
        f.judul_film,
        f.genre_film,
        f.harga_tiket,
        f.poster_film
      FROM ${DBHelper.tableJadwal} j
      JOIN ${DBHelper.tableFilm} f ON j.film_id = f.film_id
      WHERE j.film_id = ?
      ORDER BY j.waktu_tayang ASC
    ''',
      [filmId],
    );
  }

  // ==================== TRANSAKSI OPERATIONS ====================

  /// Insert transaksi baru
  Future<int> insertTransaksi(Map<String, dynamic> transaksi) async {
    final db = await _dbHelper.database;
    return await db.insert(DBHelper.tableTransaksi, transaksi);
  }

  /// Get semua transaksi
  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableTransaksi,
      orderBy: 'transaksi_id DESC',
    );

    return result;
  }

  /// Get transaksi by user ID
  Future<List<Map<String, dynamic>>> getTransaksiByUserId(int userId) async {
    final db = await _dbHelper.database;
    return await db.query(
      DBHelper.tableTransaksi,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaksi_id DESC',
    );
  }

  /// Get transaksi aktif (status = completed) by user ID
  Future<List<Map<String, dynamic>>> getActiveTransaksiByUserId(
    int userId,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      DBHelper.tableTransaksi,
      where: 'user_id = ? AND status_pembelian = ?',
      whereArgs: [userId, 'completed'],
      orderBy: 'transaksi_id DESC',
    );
  }

  /// Get transaksi by ID
  Future<Map<String, dynamic>?> getTransaksiById(int transaksiId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DBHelper.tableTransaksi,
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get transaksi dengan detail lengkap (JOIN dengan Film dan Jadwal)
  Future<List<Map<String, dynamic>>> getTransaksiWithDetails(int userId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT 
        t.*,
        f.judul_film,
        f.genre_film,
        f.poster_film,
        j.waktu_tayang
      FROM ${DBHelper.tableTransaksi} t
      JOIN ${DBHelper.tableJadwal} j ON t.jadwal_id = j.jadwal_id
      JOIN ${DBHelper.tableFilm} f ON j.film_id = f.film_id
      WHERE t.user_id = ?
      ORDER BY t.transaksi_id DESC
    ''',
      [userId],
    );
  }

  /// Get transaksi detail by ID (JOIN)
  Future<Map<String, dynamic>?> getTransaksiDetailById(int transaksiId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        t.*,
        f.judul_film,
        f.genre_film,
        f.poster_film,
        j.waktu_tayang
      FROM ${DBHelper.tableTransaksi} t
      JOIN ${DBHelper.tableJadwal} j ON t.jadwal_id = j.jadwal_id
      JOIN ${DBHelper.tableFilm} f ON j.film_id = f.film_id
      WHERE t.transaksi_id = ?
    ''',
      [transaksiId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Update transaksi
  Future<int> updateTransaksi(
    int transaksiId,
    Map<String, dynamic> transaksi,
  ) async {
    final db = await _dbHelper.database;
    return await db.update(
      DBHelper.tableTransaksi,
      transaksi,
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
  }

  /// Update status transaksi
  Future<int> updateStatusTransaksi(int transaksiId, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      DBHelper.tableTransaksi,
      {'status_pembelian': status},
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
  }

  /// Delete transaksi
  Future<int> deleteTransaksi(int transaksiId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DBHelper.tableTransaksi,
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
  }
}
