import 'package:utspam_b_0023_film/data/db/mtix_dao.dart';
import 'package:utspam_b_0023_film/data/model/user_model.dart';

class UserRepository {
  final MtixDao _dao = MtixDao();

  // Register user baru
  Future<int> registerUser({
    required String namaLengkap,
    required String email,
    required String nomorTelepon,
    String? alamat,
    required String username,
    required String password,
  }) async {
    final user = User(
      namaLengkap: namaLengkap,
      email: email,
      nomorTelepon: nomorTelepon,
      alamat: alamat,
      username: username,
      password: password,
    );
    return await _dao.insertUser(user.toMap());
  }

  // Login user dengan username
  Future<User?> login(String username, String password) async {
    final map = await _dao.getUserByCredentials(username, password);
    return map != null ? User.fromMap(map) : null;
  }

  // Login user dengan email atau username
  Future<User?> loginWithEmailOrUsername(
    String emailOrUsername,
    String password,
  ) async {
    final map = await _dao.getUserByEmailOrUsernameAndPassword(
      emailOrUsername,
      password,
    );
    return map != null ? User.fromMap(map) : null;
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    final map = await _dao.getUserById(id);
    return map != null ? User.fromMap(map) : null;
  }

  // Check if username exists
  Future<bool> isUsernameExists(String username) async {
    final user = await _dao.getUserByUsername(username);
    return user != null;
  }

  // Check if email exists
  Future<bool> isEmailExists(String email) async {
    final user = await _dao.getUserByEmail(email);
    return user != null;
  }

  // Update user
  Future<int> updateUser(User user) async {
    if (user.id == null) {
      throw Exception('User ID cannot be null for update');
    }
    return await _dao.updateUser(user.id!, user.toMap());
  }

  // Cek apakah username dan email cocok dengan user di database untuk verifikasi lupa password
  Future<User?> getUserByUsernameAndEmail(String username, String email) async {
    final map = await _dao.getUserByUsernameAndEmail(username, email);
    return map != null ? User.fromMap(map) : null;
  }

  // Update password user
  Future<int> updatePassword(int userId, String newPassword) async {
    return await _dao.updateUserPassword(userId, newPassword);
  }
}
