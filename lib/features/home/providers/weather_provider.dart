import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/weather_service.dart';
import '../../../core/env/env.dart';

// Servicio de clima (simple)
final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(),
);

// Estado de ciudad usando Notifier (en lugar de StateProvider)
final cityProvider = NotifierProvider<CityController, String>(
  CityController.new,
);

class CityController extends Notifier<String> {
  @override
  String build() => Env.defaultCity;

  void setCity(String city) {
    state = city;
  }
}

// Clima actual (se vuelve a cargar cuando cambia la ciudad)
final weatherProvider = FutureProvider.autoDispose((ref) async {
  final city = ref.watch(cityProvider);
  return ref.read(weatherServiceProvider).fetchCurrent(city);
});
