import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String dbName = 'mtix_film.db';
  static const int dbVersion = 1;

  // Table names
  static const String tableUser = 'User';
  static const String tableFilm = 'Film';
  static const String tableJadwal = 'Jadwal';
  static const String tableTransaksi = 'Transaksi';

  DBHelper._init();
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  factory DBHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(dbName);
    return _database!;
  }

  Future<Database> _initDatabase(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create User table
    await db.execute('''
      CREATE TABLE $tableUser (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_lengkap VARCHAR NOT NULL,
        email VARCHAR NOT NULL UNIQUE,
        alamat TEXT,
        nomor_telepon VARCHAR NOT NULL,
        username VARCHAR NOT NULL UNIQUE,
        password VARCHAR NOT NULL
      )
    ''');

    // Create Film table
    await db.execute('''
      CREATE TABLE $tableFilm (
        film_id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul_film VARCHAR NOT NULL,
        genre_film VARCHAR,
        harga_tiket INTEGER NOT NULL,
        poster_film VARCHAR
      )
    ''');

    // Create Jadwal table
    await db.execute('''
      CREATE TABLE $tableJadwal (
        jadwal_id INTEGER PRIMARY KEY AUTOINCREMENT,
        film_id INTEGER NOT NULL,
        waktu_tayang DATETIME NOT NULL,
        FOREIGN KEY (film_id) REFERENCES $tableFilm(film_id) ON DELETE CASCADE
      )
    ''');

    // Create Transaksi table
    await db.execute('''
      CREATE TABLE $tableTransaksi (
        transaksi_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        jadwal_id INTEGER NOT NULL,
        nama_pembeli VARCHAR NOT NULL,
        jumlah_tiket INTEGER NOT NULL,
        tanggal_pembelian DATE NOT NULL,
        total_biaya INTEGER NOT NULL,
        metode_pembayaran VARCHAR NOT NULL,
        nomor_kartu VARCHAR,
        status_pembelian VARCHAR NOT NULL DEFAULT 'completed',
        FOREIGN KEY (user_id) REFERENCES $tableUser(user_id) ON DELETE CASCADE,
        FOREIGN KEY (jadwal_id) REFERENCES $tableJadwal(jadwal_id) ON DELETE CASCADE
      )
    ''');

    // Insert dummy data for testing
    await _insertDummyData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Drop tables and recreate (simple migration strategy)
      await db.execute('DROP TABLE IF EXISTS $tableTransaksi');
      await db.execute('DROP TABLE IF EXISTS $tableJadwal');
      await db.execute('DROP TABLE IF EXISTS $tableFilm');
      await db.execute('DROP TABLE IF EXISTS $tableUser');
      await _onCreate(db, newVersion);
    }
  }

  // Insert dummy data for testing
  Future<void> _insertDummyData(Database db) async {
    // Insert dummy user
    await db.insert(tableUser, {
      'nama_lengkap': 'Muhammad Muqoffin Nuha',
      'email': 'muqoffin@mtix.com',
      'alamat': 'Gresik, Indonesia',
      'nomor_telepon': '081234567890',
      'username': 'muqoffin',
      'password': 'password123',
    });

    // Insert dummy films
    final filmIds = <int>[];

    filmIds.add(
      await db.insert(tableFilm, {
        'judul_film': 'Spider-Man: No Way Home',
        'genre_film': 'Action, Adventure',
        'harga_tiket': 50000,
        'poster_film':
            'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=500',
      }),
    );

    filmIds.add(
      await db.insert(tableFilm, {
        'judul_film': 'The Batman',
        'genre_film': 'Action, Crime, Drama',
        'harga_tiket': 55000,
        'poster_film':
            'https://images.unsplash.com/photo-1509347528160-9a9e33742cdb?w=500',
      }),
    );

    filmIds.add(
      await db.insert(tableFilm, {
        'judul_film': 'Dune: Part Two',
        'genre_film': 'Sci-Fi, Adventure',
        'harga_tiket': 60000,
        'poster_film':
            'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=500',
      }),
    );

    filmIds.add(
      await db.insert(tableFilm, {
        'judul_film': 'Oppenheimer',
        'genre_film': 'Biography, Drama, History',
        'harga_tiket': 65000,
        'poster_film':
            'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=500',
      }),
    );

    // Insert dummy schedules for each film
    for (var filmId in filmIds) {
      await db.insert(tableJadwal, {
        'film_id': filmId,
        'waktu_tayang': DateTime.now()
            .add(const Duration(hours: 2))
            .toIso8601String(),
      });
      await db.insert(tableJadwal, {
        'film_id': filmId,
        'waktu_tayang': DateTime.now()
            .add(const Duration(hours: 5))
            .toIso8601String(),
      });
      await db.insert(tableJadwal, {
        'film_id': filmId,
        'waktu_tayang': DateTime.now()
            .add(const Duration(hours: 8))
            .toIso8601String(),
      });
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Delete database (for testing)
  Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await deleteDatabase(path);
    _database = null;
  }
}
