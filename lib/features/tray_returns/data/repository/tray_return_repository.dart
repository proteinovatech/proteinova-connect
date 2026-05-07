import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/branch/tray_returns/data/model/tray_return_model.dart';


class TrayReturnRepository {
  Future<TrayReturnModel>
      fetchTrayReturnData() async {
     final response =
        await http.get(
   Uri.parse(ApiConstants.dashboard),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decodedData =
          jsonDecode(response.body);

      return TrayReturnModel.fromJson(
        decodedData,
      );
    } else {
      throw Exception(
        "Failed to load tray return data",
      );
    }
  }
}