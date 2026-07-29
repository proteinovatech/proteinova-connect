import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';

class AuthService {
  static final String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiConfig.login}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "role": role}),
    );
    print("Login Status: ${response.statusCode}");
    print("Login Response: ${response.body}");
    print(email);
    print(password);
    print(role);
    print("STATUS CODE => ${response.statusCode}");
    print("BODY => ${response.body}");

    // if (response.statusCode == 200) {
    //   print("wwww");
    //   return jsonDecode(response.body);
    // }

    // return null;

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    if (response.statusCode == 429) {
      throw Exception(
        data["error"] ?? "Please wait 1 minute before trying again.",
      );
    }

    if (response.statusCode == 401) {
      throw Exception(data["error"] ?? "Invalid email or password");
    }

    throw Exception(data["error"] ?? data["message"] ?? "Login failed");
  }
}
