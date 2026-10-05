import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/medicine_service.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _medicines = [];
  List<dynamic> _filteredMedicines = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;
  bool _showLowStock = false;
  bool _showExpiring = false;

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await MedicineService.getAll();
      if (!mounted) return;
      setState(() {
        _medicines = res;
        _filteredMedicines = res;
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

  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = _showLowStock
            ? _medicines.where((m) => (m['stok'] ?? 0) <= (m['stok_minimum'] ?? 10)).toList()
            : _showExpiring
                ? _medicines.where((m) {
                    try {
                      final date = DateTime.parse(m['tgl_kadaluarsa']);
                      return date.difference(DateTime.now()).inDays <= 30;
                    } catch (_) {
                      return false;
                    }
                  }).toList()
                : _medicines;
      } else {
        _filteredMedicines = _medicines.where((m) {
          final name = (m['nama_obat'] ?? '').toString().toLowerCase();
          final merk = (m['merk_obat'] ?? '').toString().toLowerCase();
          final barcode = (m['barcode'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              merk.contains(query.toLowerCase()) ||
              barcode.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleLowStock() {
    setState(() {
      _showLowStock = !_showLowStock;
      _showExpiring = false;
    });
    _filterMedicines(_searchController.text);
  }

  void _toggleExpiring() {
    setState(() {
      _showExpiring = !_showExpiring;
      _showLowStock = false;
    });
    _filterMedicines(_searchController.text);
  }

  void _startBarcodeScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _BarcodeScanScreen(
          onScan: (barcode) {
            _searchController.text = barcode;
            _filterMedicines(barcode);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari obat...',
                  border: InputBorder.none,
                ),
                onChanged: _filterMedicines,
              )
            : const Text('Manajemen Obat'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredMedicines = _medicines;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: _startBarcodeScan,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'low_stock') {
                _toggleLowStock();
              } else if (value == 'expiring') {
                _toggleExpiring();
              } else if (value == 'all') {
                setState(() {
                  _showLowStock = false;
                  _showExpiring = false;
                });
                _filterMedicines(_searchController.text);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tampilkan Semua'),
              ),
              PopupMenuItem(
                value: 'low_stock',
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(_showLowStock ? '✓ Stok Menipis' : 'Stok Menipis'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expiring',
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(_showExpiring ? '✓ Kadaluarsa 30 Hari' : 'Kadaluarsa 30 Hari'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMedicines,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMedicines,
                  child: _filteredMedicines.isEmpty
                      ? const Center(child: Text('Tidak ada obat ditemukan'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredMedicines.length,
                          itemBuilder: (context, index) {
                            final drug = _filteredMedicines[index];
                            final stok = drug['stok'] ?? 0;
                            final stokMin = drug['stok_minimum'] ?? 10;
                            final isLowStock = stok <= stokMin;
                            String? expiryDate;
                            bool isExpiring = false;

                            if (drug['tgl_kadaluarsa'] != null) {
                              expiryDate = drug['tgl_kadaluarsa'].toString().substring(0, 10);
                              try {
                                final date = DateTime.parse(expiryDate);
                                isExpiring = date.difference(DateTime.now()).inDays <= 30;
                              } catch (_) {}
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isLowStock ? Colors.orange.shade100 : const Color(0xFFDBEAFE),
                                  child: Icon(
                                    Icons.medication,
                                    color: isLowStock ? Colors.orange : const Color(0xFF2563EB),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        drug['nama_obat'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (drug['barcode'] != null && drug['barcode'].toString().isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#${drug['barcode']}',
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${drug['merk_obat'] ?? ''} | Rp ${(drug['harga'] ?? 0).toString()}'),
                                    Row(
                                      children: [
                                        Text(
                                          'Stok: $stok',
                                          style: TextStyle(
                                            color: isLowStock ? Colors.red : Colors.grey.shade700,
                                            fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (isLowStock)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Menipis!',
                                              style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        if (isExpiring) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Kadaluarsa $expiryDate',
                                              style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

class _BarcodeScanScreen extends StatelessWidget {
  final Function(String) onScan;

  const _BarcodeScanScreen({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
              onScan(barcode.rawValue!);
              Navigator.pop(context);
              break;
            }
          }
        },
      ),
    );
  }
}