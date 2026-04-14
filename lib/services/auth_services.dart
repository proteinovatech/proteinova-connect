import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      print("📤 EMAIL: $email");
      print("📤 PASSWORD: $password");
      print("🌐 URL: ${ApiConfig.login}");

      final response = await http.post(
        Uri.parse("https://proteinova-system.onrender.com/login"),
 headers: {
    "Content-Type": "application/json",   
  },
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": "purchase",
        }),
      );

      // 🔍 DEBUG RESPONSE
      print("📥 STATUS CODE: ${response.statusCode}");
      print("📥 RAW BODY: ${response.body}");

      // ❗ Try parsing safely
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == 1) {
        print("✅ Login Success");
        return data;
      } else {
        print("❌ Login Failed: ${data["message"]}");
        return null;
      }
    } catch (e) {
      print("❌ ERROR: $e");
      return null;
    }
  }
}