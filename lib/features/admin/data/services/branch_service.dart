import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/admin/menu/branch_management/data/model/branch_form_data_model.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';


class BranchService {
  Future<List<BranchModel>> fetchBranches() async {
  final response = await http.get(
    Uri.parse(
      "/api/branches/2",
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final branch =
        BranchModel.fromJson(data["branch"]);

    return [branch];
  } else {
    throw Exception("Failed");
  }
}

}