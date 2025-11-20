import 'package:flutter/material.dart';
import 'package:utspam_b_0023_film/presentation/screens/auth/login_screen.dart';
import 'package:utspam_b_0023_film/presentation/screens/auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller untuk mengontrol perpindahan halaman
  final PageController _pageController = PageController();

  // Variable untuk menyiapkan halaman yang sedang aktif
  int _currentPage = 0;

  // Daftar halaman onboarding
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Lebih banyak pilihan pembayaran!',
      description:
          'Membeli tiket film semakin mudah! Ayo amankan kursimu dengan mencoba metode pembayaran baru dari kami!',
      icon: Icons.payment,
      iconColor: Colors.green,
    ),
    OnboardingPage(
      title: 'Audio, visual, dan hidangan yang sedap',
      description:
          'Dengan TIX Food, nikmati makanan sedap dari bioskop untuk pengalaman nonton maksimal.',
      icon: Icons.fastfood,
      iconColor: Colors.orange,
    ),
    OnboardingPage(
      title: 'Lebih seru dengan TIX EVENTS!',
      description:
          'Siap-siap, banyak hiburan menarik yang akan datang dengan event-event baru yang seru!',
      icon: Icons.event,
      iconColor: Colors.blue,
    ),
    OnboardingPage(
      title: 'TIX VIP, lebih seru, koin melimpah, dapat hadiah!',
      description:
          'Gabung TIX VIP dan kumpulkan koin untuk mendapatkan hadiah dan diskon.',
      icon: Icons.card_giftcard,
      iconColor: Colors.red,
    ),
  ];

  @override
  void dispose() {
    // Hapus controller saat widget dihapus untuk mencegah memory leak
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // BAGIAN 1: HEADER - Logo dan tombol lewati
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo aplikasi
                  const Text(
                    'M-TIX',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Tombol lewati onboarding
                  TextButton(
                    onPressed: () {
                      // Navigasi ke halaman login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lewati',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // BAGIAN 2: PAGE VIEW - Area konten yang bisa di-swipe
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                // Fungsi dipanggil saat halaman berubah
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Update halaman aktif
                  });
                },
                itemCount: _pages.length, // Jumlah halaman
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon ilustrasi
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: _pages[index].iconColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _pages[index].icon,
                            size: 80,
                            color: _pages[index].iconColor,
                          ),
                        ),
                        const SizedBox(height: 60),

                        // Judul halaman
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Deskripsi halaman
                        Text(
                          _pages[index].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // BAGIAN 3: BOTTOM SECTION - Indikator halaman dan tombol navigasi
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Indikator halaman (dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Warna biru gelap jika halaman aktif, abu-abu jika tidak
                          color: _currentPage == index
                              ? const Color(0xFF0F172A)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // TOMBOL NAVIGASI
                  // Jika halaman terakhir, tampilkan tombol Daftar
                  if (_currentPage == _pages.length - 1)
                    Column(
                      children: [
                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigasi ke halaman registrasi dengan login screen di belakangnya
                              // Ganti onboarding dengan login screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                              // Kemudian push register screen di atas login
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  // Jika bukan halaman terakhir, tampilkan tombol Kembali & Lanjut
                  else
                    Row(
                      children: [
                        // Tombol Kembali - hanya tampil jika bukan halaman pertama
                        if (_currentPage > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Pindah ke halaman sebelumnya
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F172A),
                                side: const BorderSide(
                                  color: Color(0xFF0F172A),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'KEMBALI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],

                        // Tombol Lanjut
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Pindah ke halaman selanjutnya
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'LANJUT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model/Class untuk menyimpan data setiap halaman onboarding
class OnboardingPage {
  final String title; // Judul halaman
  final String description; // Deskripsi halaman
  final IconData icon; // Icon yang ditampilkan
  final Color iconColor; // Warna icon

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}
