import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/model/branch_form_data_model.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';

class BranchService {
  final Dio dio = DioClient().dio;

  Future<void> createBranch({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(
        "/api/branches",
        data: data,
      );

      print(response.data);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<BranchFormDataModel> fetchBranchFormData() async {
    final response = await dio.get(
      "/api/branches/form-data",
    );

    if (response.statusCode == 200) {
      return BranchFormDataModel.fromJson(
        response.data,
      );
    } else {
      throw Exception("Failed to load form data");
    }
  }

  Future<List<BranchModel>> fetchBranches() async {
    final response = await dio.get("/api/branches");

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      print("API RESPONSE BRANCHES => ${response.data}");
      return data.map((e) => BranchModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load branches");
    }
  }

  Future<void> updateBranch({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        "/api/branches/$id",
        data: data,
      );

      print(response.data);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteBranch(int id) async {
    final response = await dio.delete("/api/branches/$id");
    if (response.statusCode != 200) {
      throw Exception("Failed to delete branch");
    }
  }
}