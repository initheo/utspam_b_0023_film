import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:utspam_b_0023_film/data/model/film_model.dart';
import 'package:utspam_b_0023_film/data/model/transaction_model.dart';
import 'package:utspam_b_0023_film/data/repository/schedule_repository.dart';
import 'package:utspam_b_0023_film/data/repository/transaction_repository.dart';
import 'package:utspam_b_0023_film/data/repository/user_repository.dart';
import 'package:utspam_b_0023_film/presentation/screens/transaction/transaction_success_screen.dart';
import 'package:utspam_b_0023_film/utils/formatters.dart';
import 'package:utspam_b_0023_film/utils/ui_helpers.dart';

class PurchaseTicketScreen extends StatefulWidget {
  final int userId;
  final Film film;
  final String selectedSchedule;

  const PurchaseTicketScreen({
    super.key,
    required this.userId,
    required this.film,
    required this.selectedSchedule,
  });

  @override
  State<PurchaseTicketScreen> createState() => _PurchaseTicketScreenState();
}

class _PurchaseTicketScreenState extends State<PurchaseTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionRepository = TransactionRepository();
  final _jadwalRepository = ScheduleRepository();
  final _userRepository = UserRepository();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dateController = TextEditingController();
  final _cardNumberController = TextEditingController();

  String _paymentMethod = 'Cash';
  int _quantity = 0;
  int _totalPrice = 0;
  DateTime? _selectedDate;
  int? _userId;
  int? _jadwalId;

  @override
  void initState() {
    super.initState();
    _loadUserAndJadwal();

    // Hitung ulang total harga setiap kali jumlah tiket berubah
    _quantityController.addListener(_calculateTotal);

    // Set tanggal pembelian otomatis ke tanggal dan jam sekarang
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(_selectedDate!);
  }

  // Mencari jadwal_id dari database berdasarkan film dan waktu tayang
  Future<void> _loadUserAndJadwal() async {
    try {
      // Set userId dari widget parameter
      setState(() {
        _userId = widget.userId;
      });

      // Ambil data user dari database
      final user = await _userRepository.getUserById(widget.userId);
      if (user != null) {
        setState(() {
          _nameController.text = user.namaLengkap;
        });
      }

      // Ambil semua jadwal untuk film ini
      final jadwals = await _jadwalRepository.getJadwalByFilmId(
        widget.film.id!,
      );
      // Cari jadwal yang waktu_tayang-nya cocok dengan selectedSchedule
      final matchingJadwal = jadwals.firstWhere(
        (j) => j.waktuTayang == widget.selectedSchedule,
        orElse: () => throw Exception('Jadwal tidak ditemukan'),
      );

      setState(() {
        _jadwalId = matchingJadwal.id; // Simpan jadwal_id
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  // Fungsi untuk menghitung total pembelian secara real-time
  void _calculateTotal() {
    setState(() {
      _quantity = int.tryParse(_quantityController.text) ?? 0;
      _totalPrice = widget.film.ticketPrice * _quantity;
    });
  }

  // Fungsi untuk menyimpan transaksi
  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null || _jadwalId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data tidak lengkap')));
        return;
      }

      // Tampilkan loading
      UIHelpers.showLoadingDialog(context);

      try {
        final transaction = TicketTransaction(
          userId: _userId!,
          jadwalId: _jadwalId!,
          namaPembeli: _nameController.text,
          jumlahTiket: _quantity,
          tanggalPembelian: _dateController.text,
          totalHarga: _totalPrice,
          metodePembayaran: _paymentMethod,
          nomorKartu: _paymentMethod == 'Card'
              ? _cardNumberController.text
              : null,
          status: 'selesai',
          filmTitle: widget.film.title,
          filmPosterUrl: widget.film.posterUrl,
          filmGenre: widget.film.genre,
          schedule: widget.selectedSchedule,
        );

        // Simpan ke database
        await _transactionRepository.saveTransaction(transaction);

        // Simulasi delay
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pop(context); // Tutup loading

          // Navigasi ke halaman sukses
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionSuccessScreen(
                userId: widget.userId,
                userName: _nameController.text,
                filmTitle: widget.film.title,
                filmPosterUrl: widget.film.posterUrl,
                schedule: widget.selectedSchedule,
                quantity: _quantity,
                purchaseDate: _dateController.text,
                totalPrice: _totalPrice,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.hideLoadingDialog(context); // Tutup loading
          UIHelpers.showErrorSnackBar(context, 'Terjadi kesalahan: $e');
        }
      }
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
          'Formulir Pembelian Tiket',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Detail Film Section
            _buildFilmDetailSection(),
            const SizedBox(height: 24),

            // Form Section
            const Text(
              'Detail Pembelian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Nama Pembeli (Read-only - diambil dari username yang login)
            TextFormField(
              controller: _nameController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Nama Pembeli',
                hintText: 'Diambil dari akun yang login',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Jumlah Tiket
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah Tiket',
                hintText: 'Masukkan jumlah tiket',
                prefixIcon: const Icon(Icons.confirmation_num_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0F172A)),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tiket wajib diisi';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Jumlah tiket harus berupa angka positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tanggal Pembelian (Otomatis diisi dengan tanggal dan jam sekarang)
            TextFormField(
              controller: _dateController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Tanggal Pembelian',
                hintText: 'Tanggal dan jam saat transaksi',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Total Pembelian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0F172A).withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembelian:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(_totalPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metode Pembayaran
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Radio Button Cash
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _paymentMethod == 'Cash'
                      ? const Color(0xFF0F172A)
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                title: const Text('Cash'),
                value: 'Cash',
                groupValue: _paymentMethod,
                activeColor: const Color(0xFF0F172A),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                    _cardNumberController.clear();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // Radio Button Kartu Debit/Kredit
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _paymentMethod == 'Card'
                      ? const Color(0xFF0F172A)
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                title: const Text('Kartu Debit/Kredit'),
                value: 'Card',
                groupValue: _paymentMethod,
                activeColor: const Color(0xFF0F172A),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Nomor Kartu (hanya muncul jika metode pembayaran Card)
            if (_paymentMethod == 'Card')
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor Kartu Debit/Kredit',
                  hintText: 'Masukkan 16 digit nomor kartu',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0F172A)),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (value) {
                  if (_paymentMethod == 'Card') {
                    if (value == null || value.isEmpty) {
                      return 'Nomor kartu wajib diisi';
                    }
                    if (value.length != 16) {
                      return 'Nomor kartu harus berisi 16 digit angka';
                    }
                  }
                  return null;
                },
              ),
            const SizedBox(height: 32),

            // Tombol Submit
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Konfirmasi Pembelian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan detail film
  Widget _buildFilmDetailSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Detail Film',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Film
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.film.posterUrl,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 140,
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
              // Detail Film
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.film.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.movie_filter,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.film.genre,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Jam Tayang: ${Formatters.formatScheduleTime(widget.selectedSchedule)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                        widget.film.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
