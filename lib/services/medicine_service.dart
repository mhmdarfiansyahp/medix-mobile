import 'api_client.dart';

class MedicineService {
  static Future<List<dynamic>> getAll() async {
    final res = await ApiClient.get('/medicines');
    return (res as List?) ?? [];
  }

  static Future<Map<String, dynamic>> getByBarcode(String barcode) async {
    final res = await ApiClient.get('/medicines/barcode/$barcode');
    return res as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getLowStock() async {
    final res = await ApiClient.get('/medicines/alerts/low-stock');
    return (res as List?) ?? [];
  }

  static Future<List<dynamic>> getExpiring({int days = 30}) async {
    final res = await ApiClient.get('/medicines/alerts/expiring?days=$days');
    return (res as List?) ?? [];
  }
}
