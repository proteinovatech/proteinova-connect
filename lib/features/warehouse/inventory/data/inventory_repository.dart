import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/warehouse/inventory/models/inventory_model.dart';

class InventoryRepository {
  Future<AdminInventoryModel> fetchInventoryData({int? branchId}) async {
    try {
      final url = branchId != null
          ? "${ApiConstants.branchIncomingStock}/$branchId"
          : ApiConstants.adminInventory;

      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AdminInventoryModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception("Failed to load inventory data");
      }
    } catch (e) {
      throw Exception("Error fetching inventory: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRawInventoryData() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.adminInventory),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] is Map<String, dynamic> ? data['data'] : (data is Map<String, dynamic> ? data : {});
      } else {
        throw Exception("Failed to load raw inventory data");
      }
    } catch (e) {
      throw Exception("Error fetching raw inventory: $e");
    }
  }

  //
  Future<Map<String, dynamic>> fetchPurchaseById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.purchaseList}/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['data'] ?? {};
      } else {
        throw Exception("Failed to load purchase");
      }
    } catch (e) {
      throw Exception("Error fetching purchase: $e");
    }
  }

  // Future<void> receiveStock(int branchId, int dispatchId) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //         "${ApiConstants.branchIncomingStock}/$branchId/dispatch/$dispatchId/receive",
  //       ),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Accept": "application/json",
  //       },
  //       body: jsonEncode({
  //         "items": [],
  //       }), // Placeholder, usually needs itemdetails
  //     );

  //     if (response.statusCode != 200) {
  //       final data = jsonDecode(response.body);
  //       throw Exception(data['message'] ?? "Failed to receive stock");
  //     }
  //   } catch (e) {
  //     throw Exception("Error receiving stock: $e");
  //   }
  // }
  Future<void> receiveStock(
    int dispatchId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/api/admin/receive/$dispatchId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"items": items}),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);

        throw Exception(data['error'] ?? "Failed to receive stock");
      }
    } catch (e) {
      throw Exception("Error receiving stock: $e");
    }
  }

  Future<void> markArrival(int dispatchId) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/api/purchase/$dispatchId/movement-status"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"status": "ARRIVAL"}),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? data['message'] ?? "Failed to mark arrival");
      }
    } catch (e) {
      throw Exception("Error marking arrival: $e");
    }
  }

  Future<List<PurchaseModel>> fetchPurchases() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.purchaseList),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle potential nested 'data' from paginated responses
        dynamic listData = data['data'];
        if (listData is Map && listData.containsKey('data')) {
          listData = listData['data'];
        }

        final List<dynamic> list = (listData is List) ? listData : [];
        return list.map((e) => PurchaseModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load purchase list");
      }
    } catch (e) {
      throw Exception("Error fetching purchases: $e");
    }
  }
}
