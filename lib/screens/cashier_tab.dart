import 'package:flutter/material.dart';

class CashierTab extends StatefulWidget {
  const CashierTab({super.key});

  @override
  State<CashierTab> createState() => _CashierTabState();
}

class _CashierTabState extends State<CashierTab> {
  final List<Map<String, dynamic>> cart = [
    {'name': 'Paracetamol 500mg', 'price': 5000, 'qty': 2},
    {'name': 'Vitamin C 1000mg', 'price': 15000, 'qty': 1},
  ];

  double get total => cart.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir / Transaksi')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Rp ${item['price']} x ${item['qty']}'),
                    trailing: Text('Rp ${item['price'] * item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    Text('Rp $total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaksi berhasil disimpan! Struk siap dicetak.')),
                      );
                      setState(() => cart.clear());
                    },
                    child: const Text('Proses Pembayaran & Cetak Struk'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
