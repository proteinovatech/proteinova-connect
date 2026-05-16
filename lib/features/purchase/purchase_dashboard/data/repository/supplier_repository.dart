
import 'package:dio/dio.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_request_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/services/supplier_service.dart';


class SupplierRepository {
  final Dio dio;

  SupplierRepository(this.dio);

  Future<List<SupplierModel>> fetchSuppliers() async {
    try {
      final response = await dio.get("/api/getSupplier");

      final data = response.data['data'] as List;

      return data
          .map((json) => SupplierModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to load suppliers: $e");
    }
  }
  Future<void> postSupplier(
  SupplierRequestModel supplier,
) async {
  await SupplierService().postSupplier(supplier);
}
}