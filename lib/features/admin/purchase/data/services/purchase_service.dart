import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/purchase_model.dart';

class PurchaseService {
  final Dio dio = DioClient().dio;

  Future<void> postPurchase(PurchaseRequest purchase) async {
    try {
      final response = await dio.post(
        "/api/purchase",
        data: purchase.toJson(),
      );

      print("SUCCESS: ${response.data}");
    } catch (e) {
      print("ERROR: $e");
      rethrow;
    }
  }
  Future<List<dynamic>> getPurchases() async {
  final response = await dio.get("/api/Purchase");
  return response.data;
}
}