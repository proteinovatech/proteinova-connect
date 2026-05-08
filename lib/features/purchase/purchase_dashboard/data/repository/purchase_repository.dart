import 'package:dio/dio.dart';

import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';

class PurchaseRepository {
  final Dio dio;
  final PurchaseCacheService cache;

  PurchaseRepository(this.dio, this.cache);

  Future<List> getPurchases() async {
    try {
      final res = await dio.get('/api/purchase');
      final data = res.data['data'];

      await cache.savePurchases(data);
      return data;
    } catch (e) {
      return cache.getPurchases();
    }
  }
  
Future<Map<String, dynamic>> updateArrival(
  int purchaseId,
  Map<String, dynamic> data,
) async {
  final response = await dio.put(
    "/api/admin/arrival/$purchaseId",
    data: data,
  );

  return response.data;
}
}