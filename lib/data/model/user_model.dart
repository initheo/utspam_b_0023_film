class User {
  final int? id;
  final String namaLengkap;
  final String email;
  final String nomorTelepon;
  final String? alamat;
  final String username;
  final String password;
  final String? createdAt;

  User({
    this.id,
    required this.namaLengkap,
    required this.email,
    required this.nomorTelepon,
    this.alamat,
    required this.username,
    required this.password,
    this.createdAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'nomor_telepon': nomorTelepon,
      'alamat': alamat,
      'username': username,
      'password': password,
    };
  }

  // Create from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['user_id'],
      namaLengkap: map['nama_lengkap'],
      email: map['email'],
      nomorTelepon: map['nomor_telepon'],
      alamat: map['alamat'],
      username: map['username'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }

  // Copy with method
  User copyWith({
    int? id,
    String? namaLengkap,
    String? email,
    String? nomorTelepon,
    String? alamat,
    String? username,
    String? password,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      alamat: alamat ?? this.alamat,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
