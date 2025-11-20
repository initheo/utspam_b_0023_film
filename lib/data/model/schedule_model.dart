class Schedule {
  final int? id;
  final int filmId;
  final String waktuTayang;
  final String? createdAt;
  final String? filmTitle;
  final String? filmGenre;
  final int? filmPrice;
  final String? filmPosterUrl;

  Schedule({
    this.id,
    required this.filmId,
    required this.waktuTayang,
    this.createdAt,
    this.filmTitle,
    this.filmGenre,
    this.filmPrice,
    this.filmPosterUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'jadwal_id': id,
      'film_id': filmId,
      'waktu_tayang': waktuTayang,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['jadwal_id'],
      filmId: map['film_id'],
      waktuTayang: map['waktu_tayang'],
      createdAt: map['created_at'],
      filmTitle: map['judul_film'] ?? map['judul'],
      filmGenre: map['genre_film'] ?? map['genre'],
      filmPrice: map['harga_tiket'],
      filmPosterUrl: map['poster_film'] ?? map['poster_url'],
    );
  }

  Schedule copyWith({
    int? id,
    int? filmId,
    String? waktuTayang,
    String? createdAt,
    String? filmTitle,
    String? filmGenre,
    int? filmPrice,
    String? filmPosterUrl,
  }) {
    return Schedule(
      id: id ?? this.id,
      filmId: filmId ?? this.filmId,
      waktuTayang: waktuTayang ?? this.waktuTayang,
      createdAt: createdAt ?? this.createdAt,
      filmTitle: filmTitle ?? this.filmTitle,
      filmGenre: filmGenre ?? this.filmGenre,
      filmPrice: filmPrice ?? this.filmPrice,
      filmPosterUrl: filmPosterUrl ?? this.filmPosterUrl,
    );
  }
}
