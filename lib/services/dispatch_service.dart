import 'package:proteinova_connect/core/network/dio_client.dart';

class DispatchService {
  static final dio = DioClient().dio;

  static Future<Map<String, dynamic>?> fetchDispatchDashboard({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    try {
      final response = await dio.get(
        '/api/dispatch/dashboard',
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Error fetching dispatch dashboard: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchSingleDispatch(String id) async {
    try {
      final response = await dio.get('/api/dispatch/$id');

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Error fetching single dispatch: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchBranches() async {
    try {
      final response = await dio.get('/api/branches');
      if (response.statusCode == 200) {
        final data = response.data;
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print("Error fetching branches: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchWarehouseStock() async {
    try {
      final response = await dio.get('/api/admin/inventory');
      if (response.statusCode == 200) {
        final data = response.data;
        print("INVENTORY DATA: $data");
        
        // Try multiple common keys for the category list
        dynamic list = data['category_stock'] ?? data['inventory'] ?? data['data'] ?? [];
        if (list is Map && list.containsKey('data')) list = list['data'];
        
        final List<dynamic> stocks = (list is List) ? list : [];
        
        // Map the results with explicit type casting to avoid 'Map<String, Object>' errors
        List<Map<String, dynamic>> results = stocks.map((e) => <String, dynamic>{
          'category': (e['category'] ?? e['product_name'] ?? e['name'] ?? 'Unknown').toString(),
          'total_eggs': int.tryParse((e['total_eggs'] ?? e['stock'] ?? e['quantity'] ?? '0').toString()) ?? 0,
        }).toList();

        // 🔹 DYNAMIC DISCOVERY: Look into 'purchases' to find all categories in the database
        final List<dynamic> purchases = data['purchases'] ?? [];
        for (var p in purchases) {
          final String? catName = p['product_name'] ?? p['category'];
          if (catName != null && catName.isNotEmpty) {
            // If this category isn't in our results yet, add it with 0 stock
            if (!results.any((r) => r['category'].toString().toLowerCase() == catName.toLowerCase())) {
              results.add(<String, dynamic>{
                'category': catName,
                'total_eggs': 0,
              });
            }
          }
        }
        
        return results;
      }
      return [];
    } catch (e) {
      print("Error fetching warehouse stock: $e");
      return [];
    }
  }

  static Future<bool> createDispatch(Map<String, dynamic> dispatchData) async {
    try {
      final response = await dio.post('/api/dispatch', data: dispatchData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Create dispatch failed: ${response.data}");
        return false;
      }
    } catch (e) {
      print("Error creating dispatch: $e");
      return false;
    }
  }
}
