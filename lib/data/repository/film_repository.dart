import 'package:utspam_b_0023_film/data/db/mtix_dao.dart';
import 'package:utspam_b_0023_film/data/model/film_model.dart';

class FilmRepository {
  final MtixDao _dao = MtixDao();

  // Ambil semua film
  Future<List<Film>> getAllFilms() async {
    final maps = await _dao
        .getAllFilms(); // Ambil data dari database (bentuk Map)
    return maps.map((map) => Film.fromMap(map)).toList(); // Convert Map ke Film
  }

  // Ambil film berdasarkan ID
  Future<Film?> getFilmById(int id) async {
    final map = await _dao.getFilmById(id);
    return map != null ? Film.fromMap(map) : null;
  }

  // Ambil film beserta jadwal tayangnya
  Future<Film?> getFilmWithSchedules(int filmId) async {
    final filmMap = await _dao.getFilmById(filmId);
    if (filmMap == null) return null; // Film tidak ditemukan

    final film = Film.fromMap(filmMap);

    // Ambil jadwal tayang dari tabel jadwal
    final jadwalMaps = await _dao.getJadwalByFilmId(filmId);
    final schedules = jadwalMaps
        .map((map) => map['waktu_tayang'] as String) // Ambil waktu_tayang saja
        .toList();

    // Gabungkan schedules ke film
    return film.copyWith(schedules: schedules);
  }
}
