import 'dart:convert';

import 'package:http/http.dart'
    as http;

import 'package:proteinova_connect/core/network/api_constants.dart';

import '../model/sales_entry_model.dart';

class SalesRepository {

  Future<SalesEntryModel>
      fetchSalesEntry() async {

    final response = await http.get(

      Uri.parse(
        ApiConstants.salesEntry,
      ),

      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      return SalesEntryModel.fromJson(
        data,
      );
    } else {

      throw Exception(
        "Failed to load sales entry",
      );
    }
  }
}