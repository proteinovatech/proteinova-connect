import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/model/branch_form_data_model.dart';

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
}