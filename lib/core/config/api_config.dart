import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static String login = "$baseUrl${dotenv.env['LOGIN']}";
  static String signup = "$baseUrl${dotenv.env['SIGNUP']}";
}