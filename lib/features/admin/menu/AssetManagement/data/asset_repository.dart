import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import '../models/asset_model.dart';

class AssetRepository {
  Future<List<AssetModel>> fetchAssets() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.assets),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((e) => AssetModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load assets (Status: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching assets: $e");
    }
  }

  Future<AssetModel> createAsset(AssetModel asset) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.assets),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(asset.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AssetModel.fromJson(data['asset'] ?? data['data'] ?? data);
      } else {
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          final data = jsonDecode(response.body);
          throw Exception(data['error'] ?? "Failed to create asset");
        } else {
          throw Exception("Server Error (${response.statusCode}): Failed to create asset.");
        }
      }
    } catch (e) {
      throw Exception("Error creating asset: $e");
    }
  }

  Future<AssetModel> updateAssetStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.assets}/$id"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AssetModel.fromJson(data['asset'] ?? data['data'] ?? data);
      } else {
        // Handle non-JSON errors (like HTML error pages)
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          final data = jsonDecode(response.body);
          throw Exception(data['error'] ?? "Failed to update asset status");
        } else {
          throw Exception("Server Error (${response.statusCode}): The update endpoint might be incorrect or currently unavailable.");
        }
      }
    } catch (e) {
      throw Exception("Error updating asset status: $e");
    }
  }
}
