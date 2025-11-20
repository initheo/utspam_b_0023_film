import 'package:flutter/material.dart';
import 'package:utspam_b_0023_film/presentation/screens/films/films_screen.dart';
import 'package:utspam_b_0023_film/presentation/screens/home/home_screen.dart';
import 'package:utspam_b_0023_film/presentation/screens/profile/profile_screen.dart';
import 'package:utspam_b_0023_film/presentation/screens/tickets/my_tickets_screen.dart';

class MainNavigation extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;
  final int initialIndex;
  final String? filterGenre;
  final String? searchQuery;

  const MainNavigation({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.initialIndex = 0,
    this.filterGenre,
    this.searchQuery,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Method untuk mendapatkan halaman berdasarkan index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreenContent(
          key: ValueKey(_currentIndex),
          userId: widget.userId,
          userName: widget.userName,
        ); // Force rebuild dengan key
      case 1:
        return FilmsScreenContent(
          userId: widget.userId,
          filterGenre: widget.filterGenre,
          searchQuery: widget.searchQuery,
        );
      case 2:
        return MyTicketsScreen(userId: widget.userId);
      case 3:
        return ProfileScreen(
          userId: widget.userId,
          userName: widget.userName,
          userEmail: widget.userEmail,
        );
      default:
        return HomeScreenContent(
          userId: widget.userId,
          userName: widget.userName,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Film'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0F172A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
