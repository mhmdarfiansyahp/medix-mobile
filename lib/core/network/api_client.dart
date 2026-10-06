import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Storage {
  static String? _token;
  static DateTime? _tokenExpiry;
  static Map<String, dynamic>? _user;
  static VoidCallback? _onTokenExpired;

  static void setToken(String token, int expiresIn) {
    _token = token;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
  }

  static void setTokenExpiredListener(VoidCallback listener) {
    _onTokenExpired = listener;
  }

  static String? getToken() {
    if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
      clear();
      _onTokenExpired?.call();
      return null;
    }
    return _token;
  }

  static void setUser(Map<String, dynamic> user) => _user = user;
  static Map<String, dynamic>? getUser() => _user;
  static String? getUserRole() => _user?['role'] as String?;
  static String? getUserName() => _user?['username'] as String?;
  static void clear() {
    _token = null;
    _tokenExpiry = null;
    _user = null;
  }
}

class ApiClient {
  // Override with: flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8080
  static const String _overrideUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) return _overrideUrl;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1'; // Android emulator -> host machine
    }
    return 'http://localhost:8080/api/v1'; // desktop/web/iOS simulator
  }

  static Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = Storage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> postMultipart(String endpoint, {required String file}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(_headers());
    request.files.add(await http.MultipartFile.fromPath('file', file));
    
    final response = await request.send();
    return _handleMultipartResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) return null;
    final json = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json['data'];
    } else if (response.statusCode == 401) {
      Storage.clear();
      throw Exception('Token expired or unauthorized. Please login again.');
    } else {
      throw Exception(json['message'] ?? 'Request failed: ${response.statusCode}');
    }
  }

  static dynamic _handleMultipartResponse(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    
    if (responseBody.isEmpty) return null;
    
    try {
      final json = jsonDecode(responseBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json['data'];
      } else if (response.statusCode == 401) {
        Storage.clear();
        throw Exception('Token expired or unauthorized. Please login again.');
      } else {
        throw Exception(json['message'] ?? 'Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Invalid response format');
    }
  }
}
