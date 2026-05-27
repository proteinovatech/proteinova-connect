import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/admin/add%20branch/data/models/branch_form_options_model.dart';

class AddBranchRepository {
  final Dio dio = DioClient().dio;

  Future<BranchFormOptionsModel> fetchBranchFormOptions() async {
    try {
      final response = await dio.get('/api/branches/form-data');
      if (response.statusCode == 200) {
        return BranchFormOptionsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load branch form options');
      }
    } catch (e) {
      print('Error fetching branch form options: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBranch(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/api/branches', data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create branch');
      }
    } catch (e) {
      print('Error creating branch: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBranch(int id, Map<String, dynamic> payload) async {
    try {
      final response = await dio.put('/api/branches/$id', data: payload);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to update branch');
      }
    } catch (e) {
      print('Error updating branch: $e');
      rethrow;
    }
  }
}
