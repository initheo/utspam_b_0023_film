import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_b_0023_film/data/model/transaction_model.dart';
import 'package:utspam_b_0023_film/data/repository/transaction_repository.dart';
import 'package:utspam_b_0023_film/presentation/screens/transaction/edit_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionRepository _repository = TransactionRepository();
  TicketTransaction? _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final transaction = await _repository.getTransactionDetailById(
      widget.transactionId,
    );

    setState(() {
      _transaction = transaction;
      _isLoading = false;
    });
  }

  String _formatScheduleTime(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return isoDateTime;
    }
  }

  // Format currency ke Rupiah
  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Fungsi untuk batalkan transaksi
  Future<void> _cancelTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Transaksi'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan transaksi ini? ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Hapus transaksi dari penyimpanan lokal
      await _repository.deleteTransaction(widget.transactionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dibatalkan'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman riwayat
      }
    }
  }

  // Fungsi untuk edit transaksi
  Future<void> _editTransaction() async {
    if (_transaction == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: _transaction!),
      ),
    );

    _loadTransaction();
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
              ),
            )
          : _transaction == null
          ? const Center(child: Text('Transaksi tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster Film
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _transaction!.filmPosterUrl ?? '',
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            width: 200,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.movie,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul Film
                  Text(
                    _transaction!.filmTitle ?? '',
                    style: const TextStyle(
                      fontSize: 24,
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
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _transaction!.filmGenre ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Harga per tiket
                  Row(
                    children: [
                      const Icon(
                        Icons.local_activity,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatCurrency((_transaction!.totalHarga / _transaction!.jumlahTiket).round())} / tiket',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  const Divider(),
                  const SizedBox(height: 20),

                  // Detail Transaksi
                  const Text(
                    'Detail Pembelian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    Icons.access_time,
                    'Jadwal Film',
                    _formatScheduleTime(_transaction!.schedule),
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(
                    Icons.person,
                    'Nama Pembeli',
                    _transaction!.namaPembeli,
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(
                    Icons.confirmation_num,
                    'Jumlah Tiket',
                    '${_transaction!.jumlahTiket} Tiket',
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(
                    Icons.calendar_today,
                    'Tanggal Beli',
                    _transaction!.tanggalPembelian,
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(
                    Icons.payment,
                    'Metode Pembayaran',
                    _transaction!.metodePembayaran == 'Cash'
                        ? 'Cash'
                        : 'Kartu Debit/Kredit',
                  ),
                  const SizedBox(height: 12),

                  // Nomor Kartu (jika ada)
                  if (_transaction!.nomorKartu != null &&
                      _transaction!.nomorKartu!.isNotEmpty)
                    Column(
                      children: [
                        _buildDetailRow(
                          Icons.credit_card,
                          'Nomor Kartu',
                          _transaction!.maskedCardNumber,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Ringkasan Pembayaran
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0F172A).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Harga Tiket (${_transaction!.jumlahTiket}x)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              _formatCurrency(
                                (_transaction!.totalHarga /
                                        _transaction!.jumlahTiket)
                                    .round(),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              _formatCurrency(_transaction!.totalHarga),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _formatCurrency(_transaction!.totalHarga),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Aksi
                  Row(
                    children: [
                      // Tombol Cancel
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelTransaction,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Batalkan Transaksi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Tombol Edit (hanya muncul jika status selesai)
                      if (_transaction!.status == 'selesai') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _editTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Edit Transaksi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
