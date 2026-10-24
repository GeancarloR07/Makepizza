import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:makepizza_u/app.dart';

void main() {
  testWidgets('La app construye el MaterialApp', (WidgetTester tester) async {
    // Montamos la app con ProviderScope (Riverpod)
    await tester.pumpWidget(const ProviderScope(child: MakePizzaApp()));

    // Verificamos que exista un MaterialApp y se renderice el primer frame
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
