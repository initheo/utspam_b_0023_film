import 'package:flutter/material.dart';
import 'package:utspam_b_0023_film/data/model/transaction_model.dart';
import 'package:utspam_b_0023_film/data/repository/transaction_repository.dart';
import 'package:utspam_b_0023_film/presentation/screens/transaction/transaction_detail_screen.dart';
import 'package:utspam_b_0023_film/utils/formatters.dart';

class MyTicketsScreen extends StatefulWidget {
  final int userId;

  const MyTicketsScreen({super.key, required this.userId});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final TransactionRepository _repository = TransactionRepository();

  // Format currency ke Rupiah

  void _reloadData() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Tiket',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<TicketTransaction>>(
        // Ambil data riwayat tiket dengan detail lengkap dari database
        future: _repository.getTransactionsWithDetails(userId: widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tickets = snapshot.data ?? [];

          final activeTickets = tickets
              .where((t) => t.status == 'selesai')
              .toList();

          if (activeTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_num_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Riwayat Tiket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tiket yang Anda beli akan muncul di sini',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeTickets.length,
            itemBuilder: (context, index) {
              final ticket = activeTickets[index];
              return _buildTicketCard(context, ticket);
            },
          );
        },
      ),
    );
  }

  // Widget untuk card tiket
  // Menampilkan: Poster Film, Nama Pembeli, Total Biaya
  Widget _buildTicketCard(BuildContext context, TicketTransaction ticket) {
    return GestureDetector(
      onTap: () async {
        if (ticket.id == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailScreen(transactionId: ticket.id!),
          ),
        );
        _reloadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Poster Film
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ticket.filmPosterUrl ?? '',
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.movie,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Detail Transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ticket.status == 'selesai' ? 'SELESAI' : 'DIBATALKAN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Judul Film
                    Text(
                      ticket.filmTitle ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Pembeli
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ticket.namaPembeli,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Jumlah
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_num,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ticket.jumlahTiket} Tiket',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Total
                    Text(
                      Formatters.formatCurrency(ticket.totalHarga),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
