import '../../../core/network/api_client.dart';

class TransactionService {
  static Future<Map<String, dynamic>> getTodaySummary() async {
    final res = await ApiClient.get('/transactions/today');
    return (res as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> createTransaction(List<Map<String, dynamic>> items) async {
    final details = items.map((i) => {
      'id_obat': i['id_obat'] ?? i['id'],
      'jumlah': i['qty'] ?? i['jumlah'],
    }).toList();

    final res = await ApiClient.post('/transactions', {'details': details});
    return (res as Map<String, dynamic>?) ?? {};
  }

  static Future<void> cancelTransaction(int id) async {
    await ApiClient.patch('/transactions/$id/cancel', {});
  }

  static Future<Map<String, dynamic>> getReceipt(int id) async {
    final res = await ApiClient.get('/transactions/$id/receipt');
    return (res as Map<String, dynamic>?) ?? {};
  }
}
