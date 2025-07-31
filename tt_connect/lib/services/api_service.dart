import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    return headers;
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> login(String empId, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'empId': empId,
        'password': password,
      }),
    );
    return response;
  }

  static Future<http.Response> getUserProfile(String empId) async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users/$empId'),
      headers: headers,
    );
    return response;
  }
}