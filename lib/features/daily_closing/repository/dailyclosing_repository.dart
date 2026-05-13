import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyClosingRepository {
  Future<Map<String, dynamic>> closeDay() async {
    final url = Uri.parse("https://proteinova-system.onrender.com");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "branch_id": 1,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}