// lib/main.dart
// Punto de entrada: inicializa bindings, .env y Firebase antes de montar la app.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'tooling/seed/auto_seed_service.dart';

Future<void> main() async {
  // Asegura que los plugins nativos estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // Carga .env de forma segura (si no existe, no crashea)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Puedes hacer print si quieres loguear que no encontró .env
  }

  // Inicializa Firebase (usa google-services.json en Android)
  await Firebase.initializeApp();

  await AutoSeeder.run();

  // Manejo global de errores (evita cierres silenciosos)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Monta la app con Riverpod
  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: MakePizzaApp()));
    },
    (error, stack) {
      // print(error);
    },
  );
}
