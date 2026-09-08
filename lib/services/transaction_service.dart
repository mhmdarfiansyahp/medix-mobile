import 'api_client.dart';

class TransactionService {
  static Future<Map<String, dynamic>> getTodaySummary() async {
    final res = await ApiClient.get('/transactions/today');
    return (res as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> createTransaction(List<Map<String, dynamic>> items) async {
    final res = await ApiClient.post('/transactions', {'items': items});
    return (res as Map<String, dynamic>?) ?? {};
  }
}
