import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // para leer perfil
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';

/// Servicio de auth
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Estado de auth (user de Firebase o null)
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authServiceProvider).authStateChanges(),
);
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

/// Perfil de usuario desde Firestore (users/{uid}) en tiempo real.
/// Devuelve null si no hay sesión o si el doc no existe.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;

  final uid = user?.uid;
  if (uid == null) {
    return const Stream<UserProfile?>.empty();
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data()!;
        // Aseguramos que venga el id
        return UserProfile.fromMap({...data, 'id': doc.id});
      });
});
