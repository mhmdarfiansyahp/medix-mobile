import 'package:flutter/material.dart';
import '../../cashier/services/transaction_service.dart';
import '../../inventory/services/medicine_service.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isLoading = true;
  double _totalSales = 0;
  int _totalTx = 0;
  List<dynamic> _lowStockDrugs = [];
  List<dynamic> _expiringDrugs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final summaryRes = await TransactionService.getTodaySummary();
      final lowStockRes = await MedicineService.getLowStock();
      final expiringRes = await MedicineService.getExpiring(days: 30);

      if (!mounted) return;
      final summary = summaryRes['summary'] as Map<String, dynamic>?;
      setState(() {
        _totalSales = (summary?['total_penjualan'] as num?)?.toDouble() ?? 0;
        _totalTx = (summary?['total_transaksi'] as num?)?.toInt() ?? 0;
        _lowStockDrugs = lowStockRes;
        _expiringDrugs = expiringRes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDashboardData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('Status API: ($_error)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                const Text('Ringkasan Penjualan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Total Penjualan', 'Rp ${_totalSales.toStringAsFixed(0)}', Icons.payments, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Transaksi', '$_totalTx Transaksi', Icons.receipt, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Peringatan Stok Menipis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _lowStockDrugs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Semua stok obat aman', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      )
                    : Column(
                        children: _lowStockDrugs.map((item) {
                          return _buildAlertTile(
                            item['nama_obat'] ?? 'Obat',
                            'Sisa stok: ${item['stok'] ?? 0} (Min: ${item['stok_minimum'] ?? 10})',
                            Colors.orange,
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 16),
                const Text('Peringatan Kadaluarsa 30 Hari', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _expiringDrugs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Tidak ada obat mendekati kadaluarsa', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      )
                    : Column(
                        children: _expiringDrugs.map((item) {
                          return _buildAlertTile(
                            item['nama_obat'] ?? 'Obat',
                            'Kadaluarsa: ${item['tgl_kadaluarsa'] ?? '-'}',
                            Colors.red,
                          );
                        }).toList(),
                      ),
              ],
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAlertTile(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}