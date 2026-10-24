import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/env/env.dart';

class WeatherService {
  Future<(double temp, String desc)?> fetchCurrent(String city) async {
    final key = Env.openWeatherKey;
    if (key.isEmpty) return null;
    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$key&units=metric&lang=es',
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final temp = (data['main']['temp'] as num).toDouble();
      final desc = (data['weather'][0]['description']).toString();
      return (temp, desc);
    }
    return null;
  }
}
