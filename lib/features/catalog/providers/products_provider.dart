import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/firestore_service.dart';

final firestoreProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final productsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.read(firestoreProvider).streamCollection('products');
});

final ingredientsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.read(firestoreProvider).streamCollection('ingredients');
});
