import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print("BASE URL => $baseUrl");

      final url = Uri.parse("$baseUrl/login");
      print("FULL URL => $url");
      print("EMAIL => '${email}'");
      print("PASSWORD => '${password}'");
      print("ROLE => '${role}'");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
          "role": role.trim(),
        }),
      );

      print("STATUS CODE => ${response.statusCode}");
      print("RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("API ERROR => ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("EXCEPTION => $e");
      return null;
    }
  }
}
