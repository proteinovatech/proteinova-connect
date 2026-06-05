import 'package:dio/dio.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/model/damage_category_model.dart';

class DamageService {

  final Dio dio;

  DamageService(this.dio);

  Future<List<DamageCategoryModel>> fetchDamageCategories({
    required int branchId,
  }) async {

    final response = await dio.get(
      "/api/branch/damage/categories",
      queryParameters: {
        "branch_id": branchId,
      },
    );

    final List categories = response.data['categories'];

    return categories
        .map((e) => DamageCategoryModel.fromJson(e))
        .toList();
  }
}