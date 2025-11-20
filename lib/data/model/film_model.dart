class Film {
  final int? id;
  final String title;
  final String genre;
  final int ticketPrice;
  final String posterUrl;
  final String? createdAt;

  // Optional: Jadwal tayang (diload terpisah dari tabel jadwal)
  final List<String>? schedules;

  Film({
    this.id,
    required this.title,
    required this.genre,
    required this.ticketPrice,
    required this.posterUrl,
    this.createdAt,
    this.schedules,
  });

  /// GETTER: Format harga ke Rupiah dengan pemisah ribuan
  //  Contoh: 50000 → "Rp 50.000"
  String get formattedPrice {
    return 'Rp ${ticketPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'film_id': id,
      'judul_film': title,
      'genre_film': genre,
      'harga_tiket': ticketPrice,
      'poster_film': posterUrl,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Film.fromMap(Map<String, dynamic> map) {
    return Film(
      id: map['film_id'],
      title: map['judul_film'] ?? map['judul'] ?? '',
      genre: map['genre_film'] ?? map['genre'] ?? '',
      ticketPrice: map['harga_tiket'] ?? 0,
      posterUrl: map['poster_film'] ?? map['poster_url'] ?? '',
      createdAt: map['created_at'],
    );
  }

  Film copyWith({
    int? id,
    String? title,
    String? genre,
    int? ticketPrice,
    String? posterUrl,
    String? createdAt,
    List<String>? schedules,
  }) {
    return Film(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      posterUrl: posterUrl ?? this.posterUrl,
      createdAt: createdAt ?? this.createdAt,
      schedules: schedules ?? this.schedules,
    );
  }
}
