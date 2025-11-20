import 'package:utspam_b_0023_film/data/db/mtix_dao.dart';
import 'package:utspam_b_0023_film/data/model/transaction_model.dart';

class TransactionRepository {
  final MtixDao _dao = MtixDao();

  // Simpan transaksi baru
  Future<int> saveTransaction(TicketTransaction transaction) async {
    return await _dao.insertTransaksi(transaction.toMap());
  }

  // Ambil semua transaksi
  Future<List<TicketTransaction>> getAllTransactions() async {
    final maps = await _dao.getAllTransaksi();
    return maps.map((map) => TicketTransaction.fromMap(map)).toList();
  }

  // Ambil transaksi berdasarkan User ID
  Future<List<TicketTransaction>> getTransactionsByUserId(int userId) async {
    final maps = await _dao.getTransaksiByUserId(userId);
    return maps.map((map) => TicketTransaction.fromMap(map)).toList();
  }

  // Ambil transaksi yang aktif (selesai)
  Future<List<TicketTransaction>> getActiveTransactions({int? userId}) async {
    if (userId != null) {
      final maps = await _dao.getActiveTransaksiByUserId(userId);
      return maps.map((map) => TicketTransaction.fromMap(map)).toList();
    }
    // Jika tidak ada userId, ambil semua transaksi aktif
    final maps = await _dao.getAllTransaksi();
    final allTransactions = maps
        .map((map) => TicketTransaction.fromMap(map))
        .toList();
    return allTransactions.where((t) => t.status == 'selesai').toList();
  }

  // Ambil transaksi berdasarkan ID
  Future<TicketTransaction?> getTransactionById(int id) async {
    final map = await _dao.getTransaksiById(id);
    return map != null ? TicketTransaction.fromMap(map) : null;
  }

  // Ambil detail transaksi lengkap (dengan JOIN)
  Future<TicketTransaction?> getTransactionDetailById(int id) async {
    final map = await _dao.getTransaksiDetailById(id);
    return map != null ? TicketTransaction.fromMap(map) : null;
  }

  // Ambil transaksi dengan detail lengkap
  Future<List<TicketTransaction>> getTransactionsWithDetails({
    int? userId,
  }) async {
    if (userId != null) {
      final maps = await _dao.getTransaksiWithDetails(userId);
      return maps.map((map) => TicketTransaction.fromMap(map)).toList();
    }
    // Untuk semua user
    final maps = await _dao.getAllTransaksi();
    return maps.map((map) => TicketTransaction.fromMap(map)).toList();
  }

  // Update data transaksi
  Future<int> updateTransaction(TicketTransaction transaction) async {
    if (transaction.id == null) {
      throw Exception('Transaction ID cannot be null for update');
    }
    return await _dao.updateTransaksi(transaction.id!, transaction.toMap());
  }

  // Update status transaksi
  Future<int> updateTransactionStatus(int id, String status) async {
    return await _dao.updateStatusTransaksi(id, status);
  }

  // Batalkan transaksi
  Future<int> cancelTransaction(int id) async {
    return await _dao.updateStatusTransaksi(id, 'batal');
  }

  // Hapus transaksi
  Future<int> deleteTransaction(int id) async {
    return await _dao.deleteTransaksi(id);
  }
}
