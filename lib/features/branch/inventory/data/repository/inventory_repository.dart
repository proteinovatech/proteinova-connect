import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/branch/inventory/data/model/inventory_model.dart';



class InventoryRepository {

  Future<InventoryModel>
      fetchInventory() async {

    final response =
        await http.get(
   Uri.parse(ApiConstants.dashboard as String),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      return InventoryModel.fromJson(
        data,
      );
    } else {

      throw Exception(
        "Failed to load inventory",
      );
    }
  }
}