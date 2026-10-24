import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  /// Sube una imagen de perfil a `users/{uid}/avatar.jpg` y devuelve la URL pública.
  Future<String> uploadUserAvatar({
    required String uid,
    required XFile file,
  }) async {
    final ref = _storage.ref().child('users/$uid/avatar.jpg');
    final task = await ref.putFile(File(file.path));
    final url = await task.ref.getDownloadURL();
    return url;
  }
}
