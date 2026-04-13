import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? " https://proteinova-system.onrender.com";

  static final String login =
      "$baseUrl${'/login'}";

  static final String signup =
      "$baseUrl${'/signup'}";
}