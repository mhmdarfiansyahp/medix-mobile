import 'api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await ApiClient.post('/users/login', {
      'username': username,
      'password': password,
    });
    if (res != null && res['token'] != null) {
      Storage.setToken(res['token']);
      if (res['user'] != null) Storage.setUser(res['user']);
    }
    return res as Map<String, dynamic>;
  }

  static void logout() {
    Storage.clear();
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiClient.get('/users/profile');
    if (res != null) Storage.setUser(res);
    return res as Map<String, dynamic>;
  }
}
