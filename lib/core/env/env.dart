import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get appName => dotenv.env['APP_NAME'] ?? 'MakePizza U';
  static String get googleMapsKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get openWeatherKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static String get paypalClientIdSandbox =>
      dotenv.env['PAYPAL_CLIENT_ID_SANDBOX']?.trim() ?? '';
  static double get pizzeriaLat =>
      double.tryParse(dotenv.env['PIZZERIA_LAT'] ?? '') ?? 4.7110;
  static double get pizzeriaLng =>
      double.tryParse(dotenv.env['PIZZERIA_LNG'] ?? '') ?? -74.0721;
  static String get defaultCity => dotenv.env['DEFAULT_CITY'] ?? 'Bogota';
}
