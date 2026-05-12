import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "role": role}),
    );
    print(email);
    print(password);
    print(role);

    if (response.statusCode == 200) {
      print("wwww");
      return jsonDecode(response.body);
    }
    return null;
  }
}
