import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utspam_b_0023_film/data/model/transaction_model.dart';
import 'package:utspam_b_0023_film/data/repository/transaction_repository.dart';
import 'package:utspam_b_0023_film/utils/formatters.dart';

class EditTransactionScreen extends StatefulWidget {
  final TicketTransaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TransactionRepository();

  late TextEditingController _quantityController;
  late TextEditingController _cardNumberController;

  late String _paymentMethod;
  late int _quantity;
  late int _totalPrice;

  // Harga per tiket
  int get _pricePerTicket =>
      widget.transaction.totalHarga ~/ widget.transaction.jumlahTiket;

  @override
  void initState() {
    super.initState();

    _quantityController = TextEditingController(
      text: widget.transaction.jumlahTiket.toString(),
    );
    _cardNumberController = TextEditingController(
      text: widget.transaction.nomorKartu ?? '',
    );

    _paymentMethod = widget.transaction.metodePembayaran;
    _quantity = widget.transaction.jumlahTiket;
    _totalPrice = widget.transaction.totalHarga;

    _quantityController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  // Fungsi untuk menghitung total pembelian secara real-time
  void _calculateTotal() {
    setState(() {
      _quantity = int.tryParse(_quantityController.text) ?? 0;
      _totalPrice = _pricePerTicket * _quantity;
    });
  }

  // Fungsi untuk update transaksi
  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
          ),
        ),
      );

      try {
        final updatedTransaction = widget.transaction.copyWith(
          jumlahTiket: _quantity,
          totalHarga: _totalPrice,
          metodePembayaran: _paymentMethod,
          nomorKartu: _paymentMethod == 'Card'
              ? _cardNumberController.text
              : null,
        );

        // Update ke local storage
        await _repository.updateTransaction(updatedTransaction);

        if (mounted) {
          Navigator.pop(context);

          // Tampilkan dialog sukses
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Berhasil',
                style: TextStyle(color: Color(0xFF0F172A)),
              ),
              content: const Text('Transaksi berhasil diupdate!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pop(context); // Kembali ke detail
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Tutup loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
          'Edit Transaksi',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Info Film',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.transaction.filmTitle ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jadwal: ${Formatters.formatScheduleTime(widget.transaction.schedule)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Harga per tiket: ${Formatters.formatCurrency(_pricePerTicket)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pembelian',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Pembeli: ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        widget.transaction.namaPembeli,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tanggal: ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        widget.transaction.tanggalPembelian,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Data Yang Dapat Diubah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Jumlah Tiket
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah Tiket',
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

            // Radio Button Kartu
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

            // Tombol Aksi
            Row(
              children: [
                // Tombol Batal
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Batalkan edit dan kembali ke detail tanpa menyimpan
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Simpan
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateTransaction,
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
                      'Simpan Perubahan',
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
    );
  }
}
