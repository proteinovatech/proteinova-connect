import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SettingsService {
  final String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? "";

  Future<List<dynamic>> fetchUsersList() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/getUsersList"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchUserFormData() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/user-form-data"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"roles": [], "branches": [], "warehouses": []};
    } catch (e) {
      print("Error fetching user form data: $e");
      return {"roles": [], "branches": [], "warehouses": []};
    }
  }

  Future<bool> saveUser(Map<String, dynamic> userData, {int? userId}) async {
    try {
      final url = userId != null 
          ? Uri.parse("$baseUrl/users/$userId")
          : Uri.parse("$baseUrl/signup");
      
      final response = userId != null
          ? await http.put(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(userData))
          : await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(userData));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error saving user: $e");
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/users/$userId"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }

  Future<bool> updateProfile(int userId, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/users/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }
}
