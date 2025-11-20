import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_b_0023_film/data/model/film_model.dart';
import 'package:utspam_b_0023_film/data/repository/film_repository.dart';

class FilmsScreenContent extends StatefulWidget {
  final int userId;
  final String? filterGenre;
  final String? searchQuery;

  const FilmsScreenContent({
    super.key,
    required this.userId,
    this.filterGenre,
    this.searchQuery,
  });

  @override
  State<FilmsScreenContent> createState() => _FilmsScreenContentState();
}

class _FilmsScreenContentState extends State<FilmsScreenContent> {
  final FilmRepository _filmRepository = FilmRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Film> _films = []; // Semua film dari database
  List<Film> _filteredFilms = []; // Film yang sudah difilter/dicari
  bool _isLoading = true; // Loading indicator
  bool _isSearching = false; // Show/hide search bar
  String? _selectedGenre; // Genre yang sedang dipilih
  String _searchQuery = ''; // Query pencarian

  /// HELPER: Format hanya waktu (untuk tombol jadwal)
  /// Input: "2024-01-15T14:30:00"
  /// Output: "14:30"
  String _formatTimeOnly(String isoDateTime) {
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// HELPER: Format hanya tanggal (untuk header grup)
  /// Input: "2024-01-15T14:30:00"
  /// Output: "Monday, 15 Jan 2024"
  String _formatDateOnly(String isoDateTime) {
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('EEEE, dd MMM yyyy').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  /// HELPER: Kelompokkan jadwal berdasarkan tanggal
  /// Mengubah list jadwal menjadi Map dengan key tanggal
  ///
  /// Contoh Input: ["2024-01-15T14:30:00", "2024-01-15T16:00:00", "2024-01-16T10:00:00"]
  /// Contoh Output: {
  ///   "2024-01-15": ["2024-01-15T14:30:00", "2024-01-15T16:00:00"],
  ///   "2024-01-16": ["2024-01-16T10:00:00"]
  /// }
  Map<String, List<String>> _groupSchedulesByDate(List<String> schedules) {
    final Map<String, List<String>> grouped = {};

    for (var schedule in schedules) {
      try {
        final dateTime = DateTime.parse(schedule);
        final dateKey = DateFormat('yyyy-MM-dd').format(dateTime);

        // Buat list baru jika tanggal belum ada
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(schedule); // Tambahkan jadwal ke grup tanggal
      } catch (e) {
        // Jika gagal parse, skip schedule ini
        continue;
      }
    }

    return grouped;
  }

  @override
  void initState() {
    super.initState();

    // Set genre filter dari parameter (dari home screen)
    _selectedGenre = widget.filterGenre;

    // Jika ada search query dari home, langsung set
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchQuery = widget.searchQuery!;
      _searchController.text = widget.searchQuery!;
      _isSearching = true; // Tampilkan search bar
    }

    // Listener: Setiap kali user ketik di search, update filter
    _searchController.addListener(() {
      _searchQuery = _searchController.text;
      _applyFilter();
    });

    _loadFilms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilms() async {
    try {
      final films = await _filmRepository.getAllFilms();

      final filmsWithSchedules = await Future.wait(
        films.map((film) => _filmRepository.getFilmWithSchedules(film.id!)),
      );

      setState(() {
        _films = filmsWithSchedules.whereType<Film>().toList();
        _isLoading = false;
      });

      _applyFilter();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading films: ${e.toString()}')),
        );
      }
    }
  }

  // Filter film berdasarkan genre dan search query
  void _applyFilter() {
    setState(() {
      List<Film> filtered = _films;

      // FILTER 1: Berdasarkan genre
      if (_selectedGenre != null && _selectedGenre != 'Semua') {
        filtered = filtered.where((film) {
          return film.genre.toLowerCase().contains(
            _selectedGenre!.toLowerCase(),
          );
        }).toList();
      }

      // FILTER 2: Berdasarkan search query (judul atau genre)
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((film) {
          final titleMatch = film.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final genreMatch = film.genre.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          return titleMatch || genreMatch;
        }).toList();
      }

      _filteredFilms = filtered;
    });
  }

  // Update filter genre
  void _updateFilter(String? genre) {
    _selectedGenre = genre;
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari film...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black45),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 18),
              )
            : const Text(
                'Daftar Film',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
                _applyFilter();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Action'),
                  _buildFilterChip('Drama'),
                  _buildFilterChip('Comedy'),
                  _buildFilterChip('Horror'),
                  _buildFilterChip('Sci-Fi'),
                ],
              ),
            ),
          ),
          // Film List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFilms.isEmpty
                ? const Center(child: Text('Tidak ada film tersedia'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFilms.length,
                    itemBuilder: (context, index) {
                      final film = _filteredFilms[index];
                      return _buildFilmCard(context, film);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmCard(BuildContext context, Film film) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Film
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              film.posterUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.movie, size: 80, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          // Detail Film
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Film
                Text(
                  film.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Genre
                Row(
                  children: [
                    const Icon(
                      Icons.movie_filter,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        film.genre,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Harga Tiket
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_num,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      film.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jadwal Film (Dikelompokkan berdasarkan tanggal)
                const Text(
                  'Pilih Jadwal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Jadwal dikelompokkan berdasarkan tanggal
                if (film.schedules != null && film.schedules!.isNotEmpty)
                  ..._buildGroupedSchedules(film)
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Tidak ada jadwal tersedia',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build jadwal yang dikelompokkan berdasarkan tanggal
  List<Widget> _buildGroupedSchedules(Film film) {
    final groupedSchedules = _groupSchedulesByDate(film.schedules!);
    final widgets = <Widget>[];

    // Sort tanggal secara ascending
    final sortedDates = groupedSchedules.keys.toList()..sort();

    for (var dateKey in sortedDates) {
      final schedules = groupedSchedules[dateKey]!;

      // Header Tanggal
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            _formatDateOnly(schedules.first),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      );

      // Tombol waktu untuk tanggal tersebut
      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schedules.map((schedule) {
            final timeOnly = _formatTimeOnly(schedule);
            return _buildScheduleButton(context, film, timeOnly, schedule);
          }).toList(),
        ),
      );
    }

    return widgets;
  }

  // Widget untuk filter chip
  Widget _buildFilterChip(String label) {
    final isSelected =
        _selectedGenre == label || (_selectedGenre == null && label == 'Semua');
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.grey.shade200,
        selectedColor: const Color(0xFF0F172A),
        side: BorderSide.none,
        onSelected: (selected) {
          _updateFilter(label);
        },
      ),
    );
  }

  Widget _buildScheduleButton(
    BuildContext context,
    Film film,
    String displayTime,
    String originalSchedule,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilmScheduleDetailScreen(
              userId: widget.userId,
              film: film,
              selectedSchedule: displayTime,
              originalSchedule: originalSchedule,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        displayTime,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FilmScheduleDetailScreen extends StatelessWidget {
  final int userId;
  final Film film;
  final String selectedSchedule; // Formatted time (HH:mm)
  final String? originalSchedule; // Original ISO DateTime string

  const FilmScheduleDetailScreen({
    super.key,
    required this.userId,
    required this.film,
    required this.selectedSchedule,
    this.originalSchedule,
  });

  // Format jadwal lengkap (Hari, dd MMM yyyy - HH:mm)
  String _formatFullSchedule(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return selectedSchedule;
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('EEEE, dd MMM yyyy - HH:mm').format(dateTime);
    } catch (e) {
      return selectedSchedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Jadwal',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Film
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  film.posterUrl,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      width: 250,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.movie, size: 80, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Judul Film
            Text(
              film.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Genre
            Row(
              children: [
                const Icon(Icons.movie_filter, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    film.genre,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Jadwal dipilih (Tampilan lebih informatif dengan tanggal dan waktu)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Jadwal Tayang Dipilih',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatFullSchedule(originalSchedule),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Harga
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Harga Tiket:',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    film.formattedPrice,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Beli Tiket
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman form pembelian tiket
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseTicketScreen(
                        userId: userId,
                        film: film,
                        selectedSchedule: originalSchedule ?? selectedSchedule,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Beli Tiket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
