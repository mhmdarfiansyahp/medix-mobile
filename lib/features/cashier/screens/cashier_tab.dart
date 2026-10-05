import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/transaction_service.dart';
import '../../inventory/services/medicine_service.dart';

class CashierTab extends StatefulWidget {
  const CashierTab({super.key});

  @override
  State<CashierTab> createState() => _CashierTabState();
}

class _CashierTabState extends State<CashierTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _cart = [];
  bool _isProcessing = false;
  List<dynamic> _todayTransactions = [];
  Map<String, dynamic> _todaySummary = {};
  bool _isLoadingHistory = false;

  double get total => _cart.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['qty'] as num)));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTodayHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTodayHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final res = await TransactionService.getTodaySummary();
      if (!mounted) return;
      setState(() {
        _todayTransactions = (res['transactions'] as List?) ?? [];
        _todaySummary = (res['summary'] as Map<String, dynamic>?) ?? {};
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _processPayment() async {
    if (_cart.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final res = await TransactionService.createTransaction(_cart);
      if (!mounted) return;

      final txId = res['id_transaksi'] ?? 0;
      _showDigitalReceiptDialog(txId);

      setState(() => _cart.clear());
      _fetchTodayHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showAddMedicineModal() async {
    List<dynamic> availableMedicines = [];
    try {
      availableMedicines = await MedicineService.getAll();
    } catch (_) {}

    if (availableMedicines.isEmpty) {
      availableMedicines = [
        {'id_obat': 1, 'nama_obat': 'Paracetamol 500mg', 'harga': 5000.0, 'stok': 20},
        {'id_obat': 2, 'nama_obat': 'Amoxicillin 500mg', 'harga': 12000.0, 'stok': 15},
        {'id_obat': 3, 'nama_obat': 'Vitamin C 1000mg', 'harga': 15000.0, 'stok': 50},
      ];
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Obat untuk Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: availableMedicines.length,
                itemBuilder: (ctx, idx) {
                  final med = availableMedicines[idx];
                  final id = med['id_obat'] ?? med['id'];
                  final name = med['nama_obat'] ?? med['name'];
                  final price = (med['harga'] ?? med['price'] as num).toDouble();
                  final stok = med['stok'] ?? 0;

                  return ListTile(
                    title: Text(name),
                    subtitle: Text('Stok: $stok | Rp ${price.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                      onPressed: () {
                        setState(() {
                          final existingIdx = _cart.indexWhere((c) => c['id_obat'] == id);
                          if (existingIdx >= 0) {
                            _cart[existingIdx]['qty'] = (_cart[existingIdx]['qty'] as int) + 1;
                          } else {
                            _cart.add({'id_obat': id, 'name': name, 'price': price, 'qty': 1});
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDigitalReceiptDialog(int txId) async {
    Map<String, dynamic> receiptData = {};
    try {
      receiptData = await TransactionService.getReceipt(txId);
    } catch (_) {}

    if (!mounted) return;

    final receiptText = _buildReceiptText(receiptData, txId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text('Struk Digital #${txId > 0 ? txId : ''}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Medix Pharmacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Tanggal: Hari ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(),
              Text('Total Pembayaran: Rp ${receiptData['total_harga'] ?? total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Struk siap dicetak / dibagikan via WhatsApp.', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.green),
            tooltip: 'Bagikan Struk',
            onPressed: () {
              Share.share(receiptText, subject: 'Struk Medix Pharmacy #$txId');
              Navigator.pop(ctx);
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _buildReceiptText(Map<String, dynamic> receiptData, int txId) {
    final buffer = StringBuffer();
    buffer.writeln('=== MEDIX PHARMACY ===');
    buffer.writeln('Struk #$txId');
    buffer.writeln('Tanggal: ${DateTime.now().toString().substring(0, 10)}');
    buffer.writeln('---------------------');
    for (final item in _cart) {
      final name = item['name'] ?? '';
      final price = (item['price'] as num).toDouble();
      final qty = item['qty'] ?? 0;
      final subtotal = price * qty;
      buffer.writeln('$name');
      buffer.writeln('Rp $price x $qty = Rp $subtotal');
    }
    buffer.writeln('---------------------');
    buffer.writeln('TOTAL: Rp ${receiptData['total_harga'] ?? total.toStringAsFixed(0)}');
    buffer.writeln('=====================');
    buffer.writeln('Terima kasih!');
    return buffer.toString();
  }

  Future<void> _cancelTransaction(int id) async {
    try {
      await TransactionService.cancelTransaction(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dibatalkan! Stok telah dikembalikan.')),
      );
      _fetchTodayHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal pembatalan: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir / Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.point_of_sale), text: 'Transaksi Baru'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat Shift Hari Ini'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Keranjang Belanja', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Obat'),
                      onPressed: _showAddMedicineModal,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _cart.isEmpty
                    ? const Center(child: Text('Keranjang belanja kosong'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          final qty = item['qty'] as int;
                          final price = (item['price'] as num).toDouble();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item['name']),
                              subtitle: Text('Rp ${price.toStringAsFixed(0)} x $qty'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        if (qty > 1) {
                                          item['qty'] = qty - 1;
                                        } else {
                                          _cart.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() => item['qty'] = qty + 1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _cart.isEmpty || _isProcessing ? null : _processPayment,
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Proses Pembayaran & Cetak Struk'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchTodayHistory,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Setoran Shift Ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(
                                  'Rp ${((_todaySummary['total_penjualan'] as num?) ?? 0).toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                                ),
                              ],
                            ),
                            Chip(
                              label: Text('${_todaySummary['total_transaksi'] ?? 0} Transaksi'),
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Daftar Transaksi Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _todayTransactions.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('Belum ada transaksi hari ini'),
                              ),
                            )
                          : Column(
                              children: _todayTransactions.map((tx) {
                                final id = tx['id_transaksi'] ?? 0;
                                final status = tx['status'] ?? 1;
                                final isCancelled = status == 0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isCancelled ? Colors.red.shade100 : Colors.green.shade100,
                                      child: Icon(
                                        isCancelled ? Icons.cancel : Icons.check_circle,
                                        color: isCancelled ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    title: Text('Transaksi #$id'),
                                    subtitle: Text(
                                      'Total: Rp ${(tx['total_harga'] as num? ?? 0).toStringAsFixed(0)} ${isCancelled ? '(Dibatalkan)' : ''}',
                                      style: TextStyle(color: isCancelled ? Colors.red : Colors.black87),
                                    ),
                                    trailing: isCancelled
                                        ? const Text('Dibatalkan', style: TextStyle(color: Colors.red, fontSize: 12))
                                        : TextButton.icon(
                                            icon: const Icon(Icons.undo, size: 16, color: Colors.red),
                                            label: const Text('Batal', style: TextStyle(color: Colors.red)),
                                            onPressed: () => _cancelTransaction(id),
                                          ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}