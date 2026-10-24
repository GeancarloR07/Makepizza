// lib/data/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio sencillo para CRUD sobre Cloud Firestore.
/// Firestore es 'schemaless': la BD/colecciones se crean al escribir por primera vez.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------
  // Genéricos
  // -----------------------------

  /// Crea o reemplaza un doc con `id` fijo.
  Future<void> create(String collection, String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).set(data);
  }

  /// Crea un doc con ID automático y devuelve el ID generado.
  Future<String> add(String collection, Map<String, dynamic> data) async {
    final doc = await _db.collection(collection).add(data);
    return doc.id;
  }

  /// Crea o actualiza (merge) un documento: si no existe lo crea, si existe actualiza.
  Future<void> upsert(String collection, String id, Map<String, dynamic> data) {
    return _db
        .collection(collection)
        .doc(id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).update(data);
  }

  Future<void> delete(String collection, String id) {
    return _db.collection(collection).doc(id).delete();
  }

  Future<Map<String, dynamic>?> getById(String collection, String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    // Agregamos el id para mantener consistencia con los streams
    return {'id': doc.id, ...data};
  }

  /// Lee una colección como stream de mapas **incluyendo el doc.id** en cada item.
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection(collection)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? {},
          toFirestore: (data, _) => data,
        );

    if (orderBy != null) {
      q = q.orderBy(orderBy, descending: descending);
    }

    return q.snapshots().map((s) {
      return s.docs.map((d) {
        final data = d.data();
        // ✅ Fundamental para UI: exponer el id del documento
        return {'id': d.id, ...data};
      }).toList();
    });
  }

  // -----------------------------
  // Atajos por colección
  // -----------------------------
  CollectionReference<Map<String, dynamic>> get productsCol =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get ingredientsCol =>
      _db.collection('ingredients');
  CollectionReference<Map<String, dynamic>> get drinksCol =>
      _db.collection('drinks');
  CollectionReference<Map<String, dynamic>> get ordersCol =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get usersCol =>
      _db.collection('users');
}
