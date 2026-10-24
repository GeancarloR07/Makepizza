// lib/data/models/user_profile.dart
/// Modelo de perfil de usuario almacenado en Firestore (colección 'users').
/// Campos previstos: id, email, name (opcional), role (por defecto 'user').

class UserProfile {
  final String id; // uid de Firebase
  final String email;
  final String? name; // puede ser nulo si aún no lo guardaron
  final String role;
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.role = 'user',
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      // Aceptamos 'id' o 'uid' para ser tolerantes
      id: (map['id'] ?? map['uid'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      name: map['name'] as String?, // puede venir null
      role: (map['role'] ?? 'user') as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
