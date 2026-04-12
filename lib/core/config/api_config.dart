import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? " https://proteinova-system.onrender.com";

  static final String login =
      "$baseUrl${dotenv.env['LOGIN'] ?? '/api/login'}";

  static final String signup =
      "$baseUrl${dotenv.env['SIGNUP'] ?? '/api/signup'}";
}