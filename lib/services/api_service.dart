import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.19.5.233:8088/kaiserthefrog/sttpk2143';

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'session_token';

  // ---- token helpers ----
  static Future<void> saveToken(String t) =>
      _storage.write(key: _tokenKey, value: t);
  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // Turn the server's text reply into a Map. Never crashes.
  static Map<String, dynamic> _decode(http.Response res) {
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Unexpected server response'};
    }
  }

  static const _noServer = {
    'success': false,
    'message': 'Cannot reach the server. Check your connection.',
  };

  // ---- REGISTER ----
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String confirm) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'confirm_password': confirm,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return _decode(res);
    } catch (_) {
      return _noServer;
    }
  }

  // ---- LOGIN (saves the token if it works) ----
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      final data = _decode(res);
      if (data['success'] == true) {
        await saveToken(data['token']);
      }
      return data;
    } catch (_) {
      return _noServer;
    }
  }

  // ---- PROFILE (needs the token) ----
  static Future<Map<String, dynamic>> profile() async {
    final token = await getToken();
    if (token == null) {
      return {'success': false, 'message': 'Not logged in'};
    }
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      final data = _decode(res);
      if (res.statusCode == 401) await clearToken(); // token is no good
      return data;
    } catch (_) {
      return _noServer;
    }
  }

  // ---- LOGOUT ----
  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout.php'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 10));
      } catch (_) {}
    }
    await clearToken(); // always forget the token on the phone
  }
}