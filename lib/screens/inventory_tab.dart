import 'package:flutter/material.dart';

const analgesik = 'Analgesik';
const antibiotik = 'Antibiotik';
const suplemen = 'Suplemen';

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> drugs = [
      {'name': 'Paracetamol 500mg', 'category': analgesik, 'stock': 3, 'price': 5000},
      {'name': 'Amoxicillin 500mg', 'category': antibiotik, 'stock': 45, 'price': 12000},
      {'name': 'Vitamin C 1000mg', 'category': suplemen, 'stock': 120, 'price': 15000},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Obat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scanner Barcode Aktif')));
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drugs.length,
        itemBuilder: (context, index) {
          final drug = drugs[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.medication)),
              title: Text(drug['name']),
              subtitle: Text('Stok: ${drug['stock']} | Harga: Rp ${drug['price']}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
