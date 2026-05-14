import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';

import '../models/supplier_request_model.dart';

class SupplierService {

  final Dio dio = DioClient().dio;

  /// ADD SUPPLIER
  Future<void> postSupplier(
      SupplierRequestModel supplier) async {

    try {

      final response = await dio.post(
        "/api/addSupplier",
        data: supplier.toJson(),
      );

      print("SUCCESS: ${response.data}");

    } catch (e) {

      print("ERROR: $e");
      rethrow;
    }
  }

 /// GET SUPPLIERS
Future<List<SupplierRequestModel>>
    getSuppliers() async {
  try {
    final response = await dio.get(
      "/api/getSupplier",
    );

    List<dynamic> data = response.data['data'];

    return data
        .map(
          (e) => SupplierRequestModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  } on DioException catch (e) {

  print("STATUS CODE: ${e.response?.statusCode}");

  print("RESPONSE DATA: ${e.response?.data}");

  print("ERROR: $e");

  rethrow;
}
} 
}