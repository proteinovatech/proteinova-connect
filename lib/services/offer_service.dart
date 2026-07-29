import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OfferService {
  static Future<Map<String, dynamic>?> fetchOffers() async {
    try {
      final baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';
      final response = await http.get(
        Uri.parse("$baseUrl/api/offers"),
        headers: {"Accept": "application/json"},
      );

      print("OFFERS RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching offers: $e");
      return null;
    }
  }

  static Future<bool> createOffer(Map<String, dynamic> offerData) async {
    try {
      final baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';
      final response = await http.post(
        Uri.parse("$baseUrl/api/offers"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(offerData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error creating offer: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getCurrentPrices() async {
    try {
      final baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';
      final response = await http.get(
        Uri.parse("$baseUrl/api/admin/get_current_prices"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error fetching current prices: $e");
      return [];
    }
  }

  static Future<bool> bulkUpdatePrices(List<Map<String, dynamic>> prices) async {
    try {
      final baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';
      final response = await http.post(
        Uri.parse("$baseUrl/api/admin/bulk_update_prices"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prices": prices}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating prices: $e");
      return false;
    }
  }
}
