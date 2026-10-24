import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 faltaba
import '../../data/models/user_profile.dart';

/// Servicio de autenticación usando Firebase Auth (email/password)
class AuthService {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Registro + creación del perfil en Firestore (users/{uid})
  Future<UserCredential> register(
    String email,
    String password, {
    required String name,
  }) async {
    // 1) Crear usuario en Firebase Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    // 2) Crear/mezclar perfil en Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'id': uid,
      'email': email,
      'name': name,
      'role': 'user',
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // 👈 SetOptions es de cloud_firestore

    return cred;
  }

  /// Login; devolvemos un UserProfile simple por conveniencia en la app
  Future<UserProfile> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final u = cred.user!;
    return UserProfile(id: u.uid, email: u.email ?? email);
  }

  Future<void> logout() => _auth.signOut();
}
