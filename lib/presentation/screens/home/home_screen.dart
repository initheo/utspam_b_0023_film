import 'package:flutter/material.dart';
import 'package:utspam_b_0023_film/data/model/film_model.dart';
import 'package:utspam_b_0023_film/data/repository/film_repository.dart';
import 'package:utspam_b_0023_film/presentation/screens/main_navigation.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return MainNavigation(userId: userId, userName: userName, userEmail: '');
  }
}

/// Widget content untuk home screen
class HomeScreenContent extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeScreenContent({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final FilmRepository _filmRepository = FilmRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Film> _films = [];
  bool _isLoadingFilms = true;

  @override
  void initState() {
    super.initState();
    _loadFilms(); // Load semua film dari database
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load semua film dari database
  Future<void> _loadFilms() async {
    try {
      final films = await _filmRepository.getAllFilms();
      setState(() {
        _films = films;
        _isLoadingFilms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFilms = false;
      });
    }
  }

  // Menampilkan UI halaman home
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const Icon(Icons.location_on, color: Colors.black87),
        title: const Text(
          'Gresik, Indonesia',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari film, bioskop...',
              hintStyle: const TextStyle(color: Colors.black45),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.black87),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainNavigation(
                      userId: widget.userId,
                      userName: widget.userName,
                      userEmail: '',
                      initialIndex: 1,
                      searchQuery: value,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // Chips yang bisa diklik untuk filter berdasarkan genre
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('Action'),
                _buildFilterChip('Drama'),
                _buildFilterChip('Comedy'),
                _buildFilterChip('Horror'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Sedang Tayang'),
          const SizedBox(height: 12),
          // Tampilkan loading, empty, atau list film
          _isLoadingFilms
              ? const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _films.isEmpty
              ? const SizedBox(
                  height: 280,
                  child: Center(child: Text('Tidak ada film tersedia')),
                )
              : SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Scroll horizontal
                    itemCount: _films.length,
                    itemBuilder: (context, index) {
                      final film = _films[index];
                      return _buildMovieCardFromDb(film);
                    },
                  ),
                ),
          const SizedBox(height: 24),

          _buildSectionHeader('Informasi'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nikmati pengalaman menonton terbaik!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Beli tiket film favorit Anda dengan mudah dan cepat.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip yang bisa diklik untuk filter film berdasarkan genre
  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: Colors.black87)),
        backgroundColor: Colors.grey.shade200,
        side: BorderSide.none,
        onPressed: () {
          // Navigasi ke halaman Films dengan filter genre
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(
                userId: widget.userId,
                userName: widget.userName,
                userEmail: '',
                initialIndex: 1,
                filterGenre: label,
              ),
            ),
          );
        },
      ),
    );
  }

  // Bisa diklik untuk navigasi ke halaman Films
  Widget _buildSectionHeader(String title) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke tab Films (index 1)
        if (title == 'Sedang Tayang') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(
                userId: widget.userId,
                userName: widget.userName,
                userEmail: '',
                initialIndex: 1,
              ),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.black45, size: 20),
        ],
      ),
    );
  }

  // Card untuk menampilkan poster dan info film
  // Bisa diklik untuk navigasi ke halaman Films
  Widget _buildMovieCardFromDb(Film film) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke tab Films (index 1)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: '',
              initialIndex: 1,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            Container(
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  film.posterUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.movie, size: 60, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Movie Title
            Text(
              film.title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Movie Genre
            Text(
              film.genre,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
