import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get imgbbApiKey => dotenv.env['IMGBB_API_KEY'] ?? '';
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
}
