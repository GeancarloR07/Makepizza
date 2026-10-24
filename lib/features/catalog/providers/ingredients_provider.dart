import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'products_provider.dart';

final ingredientsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.read(firestoreProvider).streamCollection('ingredients');
});
