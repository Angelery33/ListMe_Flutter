import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Servicio singleton que envuelve las operaciones de Firebase Cloud Storage para las
/// imágenes de portada de los elementos.
///
/// Las imágenes se almacenan bajo el prefijo de bucket `items/` con un nombre derivado del
/// ID del elemento y la marca de tiempo actual para evitar colisiones.
class FirebaseStorageService {
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();

  /// Devuelve la instancia singleton de [FirebaseStorageService].
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube [imageFile] a Firebase Storage y devuelve la URL de descarga pública.
  ///
  /// El archivo se almacena bajo `items/<itemId>_<timestamp><ext>` y se sirve con
  /// un encabezado de control de caché de un año. Devuelve `null` si la subida falla.
  ///
  /// [imageFile] El archivo de imagen seleccionado por el usuario.
  /// [itemId] Un identificador único para el elemento (usado como prefijo del nombre de archivo).
  Future<String?> uploadImage(XFile imageFile, String itemId) async {
    try {
      final name = imageFile.name;
      final ext = name.contains('.') ? '.${name.split('.').last}' : '.jpg';
      final fileName = '${itemId}_${DateTime.now().millisecondsSinceEpoch}$ext';
      debugPrint('FirebaseStorage: Subiendo $fileName');
      final ref = _storage.ref().child('items').child(fileName);

      final bytes = await imageFile.readAsBytes();
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('FirebaseStorage: URL=$downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('FirebaseStorage Error: $e');
      return null;
    }
  }

  /// Sube [imageFile] como foto de perfil del usuario identificado por [userId].
  ///
  /// El archivo se almacena bajo `profiles/<userId>_<timestamp><ext>`, sustituyendo
  /// cualquier foto anterior. Devuelve la URL de descarga pública, o `null` si falla.
  ///
  /// [imageFile] El archivo de imagen seleccionado por el usuario.
  /// [userId]    Identificador único del usuario (usado como prefijo del nombre de archivo).
  Future<String?> uploadProfilePhoto(XFile imageFile, String userId) async {
    try {
      final name = imageFile.name;
      final ext = name.contains('.') ? '.${name.split('.').last}' : '.jpg';
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$ext';
      debugPrint('FirebaseStorage: Subiendo foto de perfil $fileName');
      final ref = _storage.ref().child('profiles').child(fileName);

      final bytes = await imageFile.readAsBytes();
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('FirebaseStorage: Foto de perfil URL=$downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('FirebaseStorage uploadProfilePhoto Error: $e');
      return null;
    }
  }

  /// Elimina la imagen en [imageUrl] de Firebase Storage.
  ///
  /// Ignora silenciosamente las URL nulas, vacías o que no sean HTTP para manejar elementos que no tengan
  /// imagen remota o que usen una ruta local. Los errores durante la eliminación se registran pero
  /// no se vuelven a lanzar.
  ///
  /// [imageUrl] La URL de descarga pública de Firebase Storage a eliminar, o `null`.
  Future<void> deleteImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    if (!imageUrl.startsWith('https://') && !imageUrl.startsWith('http://'))
      return;

    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('FirebaseStorage delete error: $e');
    }
  }
}
