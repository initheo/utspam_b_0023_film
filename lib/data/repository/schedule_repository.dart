import 'package:utspam_b_0023_film/data/db/mtix_dao.dart';
import 'package:utspam_b_0023_film/data/model/schedule_model.dart';

class ScheduleRepository {
  final MtixDao _dao = MtixDao();

  // Ambil jadwal berdasarkan film ID
  Future<List<Schedule>> getJadwalByFilmId(int filmId) async {
    final maps = await _dao.getJadwalByFilmId(filmId);
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // Ambil jadwal berdasarkan ID
  Future<Schedule?> getJadwalById(int id) async {
    final map = await _dao.getJadwalById(id);
    return map != null ? Schedule.fromMap(map) : null;
  }

  // Ambil jadwal dengan detail film
  Future<List<Schedule>> getJadwalWithFilmDetails(int filmId) async {
    final maps = await _dao.getJadwalWithFilmDetails(filmId);
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }
}
