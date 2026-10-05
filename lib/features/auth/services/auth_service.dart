import '../../../core/network/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await ApiClient.post('/users/login', {
      'username': username,
      'password': password,
    });
    if (res != null && res['token'] != null) {
      int expiresIn = res['expires_in'] ?? 3600; // default 1 hour
      Storage.setToken(res['token'], expiresIn);
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

  static Future<Map<String, dynamic>> updateProfile(String namaUser, String noTelp) async {
    final res = await ApiClient.put('/users/profile', {
      'nama_user': namaUser,
      'no_telp': noTelp,
    });
    if (res != null) Storage.setUser(res as Map<String, dynamic>);
    return (res as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> updateProfilePhoto(String imagePath) async {
    final res = await ApiClient.postMultipart('/users/profile/photo', file: imagePath);
    if (res != null) Storage.setUser(res as Map<String, dynamic>);
    return res as Map<String, dynamic>? ?? {};
  }
}
