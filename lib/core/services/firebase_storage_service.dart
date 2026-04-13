import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile, String itemId) async {
    if (!await imageFile.exists()) {
      debugPrint('FirebaseStorage: File no existe: ${imageFile.path}');
      return null;
    }

    try {
      final fileName =
          '${itemId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      debugPrint('FirebaseStorage: Subiendo $fileName');
      final ref = _storage.ref().child('items').child(fileName);

      final uploadTask = ref.putFile(
        imageFile,
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
