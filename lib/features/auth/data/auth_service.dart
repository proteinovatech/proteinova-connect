import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }
}