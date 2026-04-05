import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  Future<File?> pickImage({
    required ImageSource source,
    bool cropToSquare = true,
  }) async {
    final ImagePicker picker = ImagePicker();

    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        debugPrint('Camera permission denied');
        return null;
      }
    } else if (source == ImageSource.gallery) {
      final photosStatus = await Permission.photos.request();
      if (!photosStatus.isGranted && !photosStatus.isLimited) {
        debugPrint('Photos permission denied');
        return null;
      }
    }

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return null;

      if (cropToSquare) {
        final croppedFile = await _cropImage(image.path);
        return croppedFile;
      }

      return File(image.path);
    } on PlatformException catch (e) {
      debugPrint('PlatformException picking image: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Portada',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recortar Portada',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return File(imagePath);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return File(imagePath);
    }
  }

  Future<void> showImageSourceDialog(
    BuildContext context, {
    required Function(File?) onImagePicked,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(source: ImageSource.gallery);
                onImagePicked(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(source: ImageSource.camera);
                if (file == null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error al abrir cámara. Asegúrate de tener permisos.',
                      ),
                    ),
                  );
                }
                onImagePicked(file);
              },
            ),
          ],
        ),
      ),
    );
  }
}
