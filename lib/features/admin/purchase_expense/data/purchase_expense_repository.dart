import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import '../models/purchase_list_item.dart';
import '../models/purchase_detail_response.dart';
import '../models/supplier_item.dart';

class PurchaseExpenseRepository {
  final Dio _dio = DioClient().dio;

  /// Fetch all purchases from /api/purchase
  Future<List<PurchaseListItem>> fetchPurchases() async {
    try {
      final response = await _dio.get("/api/purchase");
      
      // The React app parses: res.data.data || []
      // Let's inspect the response format
      final responseData = response.data;
      List<dynamic> list = [];
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        list = responseData['data'] ?? [];
      } else if (responseData is List) {
        list = responseData;
      }

      return list.map((item) => PurchaseListItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch purchases: $e");
    }
  }

  /// Fetch single purchase detail from /api/purchase/{id}
  Future<PurchaseDetailResponse> fetchPurchaseDetail(int id) async {
    try {
      final response = await _dio.get("/api/purchase/$id");
      
      final responseData = response.data;
      Map<String, dynamic> data = {};
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        data = responseData['data'] ?? {};
      } else if (responseData is Map<String, dynamic>) {
        data = responseData;
      }

      return PurchaseDetailResponse.fromJson(data);
    } catch (e) {
      throw Exception("Failed to fetch purchase details for PO-$id: $e");
    }
  }

  /// Fetch suppliers from /api/getSupplier
  Future<List<SupplierItem>> fetchSuppliers() async {
    try {
      final response = await _dio.get("/api/getSupplier");
      
      final responseData = response.data;
      List<dynamic> list = [];
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        list = responseData['data'] ?? [];
      } else if (responseData is List) {
        list = responseData;
      }

      return list.map((item) => SupplierItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch suppliers: $e");
    }
  }

  /// Save expenses for a purchase: PUT /api/purchase/{id}/expenses
  Future<bool> saveExpenses({
    required int purchaseId,
    required double loading,
    required double unloading,
    required double transport,
  }) async {
    try {
      final response = await _dio.put(
        "/api/purchase/$purchaseId/expenses",
        data: {
          "loading": loading,
          "unloading": unloading,
          "transport": transport,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Failed to save purchase expenses: $e");
    }
  }

  /// Mark arrival: PUT /api/admin/arrival/{id}
  Future<bool> markArrival(int purchaseId) async {
    try {
      final response = await _dio.put("/api/admin/arrival/$purchaseId");
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Failed to mark arrival: $e");
    }
  }
}
