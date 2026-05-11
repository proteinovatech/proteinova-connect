import 'dart:convert';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
import 'package:proteinova_connect/core/network/api_constants.dart';
=======
import 'package:proteinova_connect/core/config/api_config.dart';
>>>>>>> ea3e69cdb2c09331bdc464ea5b45b3ec1a494c3e

class AuthService {
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
<<<<<<< HEAD
      Uri.parse("${ApiConstants.baseUrl}/login"),

=======
      Uri.parse("${ApiConfig.baseUrl}${ApiConfig.login}"),
>>>>>>> ea3e69cdb2c09331bdc464ea5b45b3ec1a494c3e
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
