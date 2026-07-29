import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';
import 'package:proteinova_connect/features/admin/supplier/data/models/supplier_model.dart';

class SupplierService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Supplier>> getSuppliers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/getSupplier'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        return data.map((json) => Supplier.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load suppliers');
      }
    } catch (e) {
      throw Exception('Error fetching suppliers: $e');
    }
  }

  Future<bool> addSupplier(Supplier supplier) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/addSupplier'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplier.toJson()),
      );

      print('Add Supplier Request: ${jsonEncode(supplier.toJson())}');
      print('Add Supplier Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add supplier');
      }
    } catch (e) {
      throw Exception('Error adding supplier: $e');
    }
  }

  Future<bool> updateSupplier(String id, Supplier supplier) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/updateSupplier/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplier.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update supplier');
      }
    } catch (e) {
      throw Exception('Error updating supplier: $e');
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/deleteSupplier/$id'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete supplier');
      }
    } catch (e) {
      throw Exception('Error deleting supplier: $e');
    }
  }
}
