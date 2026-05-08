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
 // Future<List<dynamic>> getSuppliers() async {

    //final response = await dio.get(
    //  "/api/supplier",
    //);

   // return response.data;
  //}
}