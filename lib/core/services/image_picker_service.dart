import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../i18n/l10n_extension.dart';
import 'logger_service.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  final LoggerService _logger = LoggerService.instance;
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  Future<XFile?> pickImage({
    required ImageSource source,
    bool cropToSquare = true,
  }) async {
    final ImagePicker picker = ImagePicker();

    if (!kIsWeb) {
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _logger.warning('Camera permission denied');
          return null;
        }
      } else if (source == ImageSource.gallery) {
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted && !photosStatus.isLimited) {
          _logger.warning('Photos permission denied');
          return null;
        }
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

      if (!kIsWeb && cropToSquare) {
        final File? cropped = await _cropImage(image.path);
        if (cropped != null) return XFile(cropped.path);
      }

      return image;
    } on PlatformException catch (e) {
      _logger.error('PlatformException picking image', e);
      return null;
    } catch (e) {
      _logger.error('Error picking image', e);
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
            toolbarTitle: 'Recortar',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            statusBarLight: false,
            showCropGrid: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Recortar',
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
      _logger.error('Error cropping image', e);
      return File(imagePath);
    }
  }

  Future<void> showImageSourceDialog(
    BuildContext context, {
    required Function(XFile?) onImagePicked,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.imageGallery),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(source: ImageSource.gallery);
                onImagePicked(file);
              },
            ),
            if (!kIsWeb && !Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(context.l10n.imageCamera),
                onTap: () async {
                  final cameraErr = context.l10n.imageCameraError;
                  Navigator.pop(context);
                  final file = await pickImage(source: ImageSource.camera);
                  if (file == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(cameraErr)),
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
