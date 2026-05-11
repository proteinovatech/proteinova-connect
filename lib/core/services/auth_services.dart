import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role
    
  }) async {
    final response = await http.post(
      Uri.parse("https://proteinova-system-q3ob.onrender.com/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": role,
      }),
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