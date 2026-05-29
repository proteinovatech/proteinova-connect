import 'package:dio/dio.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/model/damage_category_model.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/model/damage_history_model.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/services/damage_service.dart';

class DamageRepository {
  
  final Dio dio;

  DamageRepository(this.dio);

  late final DamageService damageService = DamageService(dio);

 Future<List<DamageCategoryModel>> getDamageCategories({
  required int branchId,
}) async {

  final response = await dio.get(
    "/api/branch/damage/categories",
    queryParameters: {
      "branch_id": branchId,
    },
  );
  print("API RESPONSE: ${response.data}");

  final List data = response.data['categories']?? [];

  return data
      .map((e) => DamageCategoryModel.fromJson(e))
      .toList();
}
Future<List<DamageHistoryModel>> getDamageHistory({
  required int branchId,
}) async {

  final response = await dio.get(
    "/api/branch/damage/history",
    queryParameters: {
      "branch_id": branchId,
    },
  );

  final List data = response.data['history']?? [];

  return data
      .map((e) => DamageHistoryModel.fromJson(e))
      .toList();
}
 Future<void> reportDamage({
    required int branchId,
    required String category,
    required String damagedEggs,
  }) async {
    try {
      final response = await dio.post(
        "/api/branch/damage",
        data: {
          "branch_id": branchId,
          "category": category,
          "damaged_eggs": damagedEggs,
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(response.data);
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data ?? e.message,
      );
    }
  }
  
}