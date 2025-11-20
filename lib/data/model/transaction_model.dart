class TicketTransaction {
  final int? id;
  final int userId;
  final int jadwalId;
  final String namaPembeli;
  final int jumlahTiket;
  final String tanggalPembelian;
  final int totalHarga;
  final String metodePembayaran;
  final String? nomorKartu;
  final String status; // 'selesai' atau 'batal'
  final String? createdAt;

  // Optional fields for joined data
  final String? filmTitle;
  final String? filmPosterUrl;
  final String? filmGenre;
  final String? schedule;

  TicketTransaction({
    this.id,
    required this.userId,
    required this.jadwalId,
    required this.namaPembeli,
    required this.jumlahTiket,
    required this.tanggalPembelian,
    required this.totalHarga,
    required this.metodePembayaran,
    this.nomorKartu,
    this.status = 'selesai',
    this.createdAt,
    this.filmTitle,
    this.filmPosterUrl,
    this.filmGenre,
    this.schedule,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'transaksi_id': id,
      'user_id': userId,
      'jadwal_id': jadwalId,
      'nama_pembeli': namaPembeli,
      'jumlah_tiket': jumlahTiket,
      'tanggal_pembelian': tanggalPembelian,
      'total_biaya': totalHarga,
      'metode_pembayaran': metodePembayaran,
      'nomor_kartu': nomorKartu,
      'status_pembelian': status,
    };
  }

  factory TicketTransaction.fromMap(Map<String, dynamic> map) {
    return TicketTransaction(
      id: map['transaksi_id'],
      userId: map['user_id'],
      jadwalId: map['jadwal_id'],
      namaPembeli: map['nama_pembeli'],
      jumlahTiket: map['jumlah_tiket'],
      tanggalPembelian: map['tanggal_pembelian'],
      totalHarga: map['total_biaya'] ?? map['total_harga'] ?? 0,
      metodePembayaran: map['metode_pembayaran'],
      nomorKartu: map['nomor_kartu'],
      status: map['status_pembelian'] ?? map['status'] ?? 'selesai',
      createdAt: map['created_at'],
      // Optional joined fields
      filmTitle: map['judul_film'] ?? map['judul'],
      filmPosterUrl: map['poster_film'] ?? map['poster_url'],
      filmGenre: map['genre_film'] ?? map['genre'],
      schedule: map['waktu_tayang'],
    );
  }

  // Format nomor kartu (sensor beberapa digit)
  String get maskedCardNumber {
    if (nomorKartu == null || nomorKartu!.isEmpty) return '';
    if (nomorKartu!.length < 4) return nomorKartu!;

    // Format: **** **** **** 1234
    final lastFour = nomorKartu!.substring(nomorKartu!.length - 4);
    return '**** **** **** $lastFour';
  }

  TicketTransaction copyWith({
    int? id,
    int? userId,
    int? jadwalId,
    String? namaPembeli,
    int? jumlahTiket,
    String? tanggalPembelian,
    int? totalHarga,
    String? metodePembayaran,
    String? nomorKartu,
    String? status,
    String? createdAt,
    String? filmTitle,
    String? filmPosterUrl,
    String? filmGenre,
    String? schedule,
  }) {
    return TicketTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jadwalId: jadwalId ?? this.jadwalId,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      jumlahTiket: jumlahTiket ?? this.jumlahTiket,
      tanggalPembelian: tanggalPembelian ?? this.tanggalPembelian,
      totalHarga: totalHarga ?? this.totalHarga,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      nomorKartu: nomorKartu ?? this.nomorKartu,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      filmTitle: filmTitle ?? this.filmTitle,
      filmPosterUrl: filmPosterUrl ?? this.filmPosterUrl,
      filmGenre: filmGenre ?? this.filmGenre,
      schedule: schedule ?? this.schedule,
    );
  }
}
