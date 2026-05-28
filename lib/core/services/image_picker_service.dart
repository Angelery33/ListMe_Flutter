import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../i18n/l10n_extension.dart';
import 'logger_service.dart';

/// Servicio singleton que maneja la selección de imágenes de la cámara o galería,
/// incluyendo solicitudes de permisos en tiempo de ejecución y recorte cuadrado opcional.
///
/// En la web se omite el paso de recorte. En plataformas de escritorio (Windows, Linux,
/// macOS) la opción de cámara está oculta en la hoja de selección de fuente.
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  final LoggerService _logger = LoggerService.instance;

  /// Devuelve la instancia singleton de [ImagePickerService].
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  /// Abre el selector de imágenes para la [source] dada y devuelve el [XFile] seleccionado,
  /// o `null` si el usuario cancela o se deniega un permiso.
  ///
  /// En plataformas que no son web, el método solicita el permiso necesario en tiempo de ejecución
  /// antes de abrir el selector. Cuando [cropToSquare] es `true` (por defecto),
  /// la imagen seleccionada se pasa a través de [ImageCropper] con una relación de aspecto bloqueada 1:1.
  ///
  /// [source] De dónde debe provenir la imagen ([ImageSource.camera] o
  /// [ImageSource.gallery]).
  /// [cropToSquare] Si se debe presentar la IU de recorte después de la selección. Por defecto es
  /// `true`. No tiene efecto en la web.
  Future<XFile?> pickImage({
    required ImageSource source,
    bool cropToSquare = true,
  }) async {
    final ImagePicker picker = ImagePicker();

    if (!kIsWeb) {
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _logger.warning('Permiso de cámara denegado');
          return null;
        }
      } else if (source == ImageSource.gallery) {
        var photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted && !photosStatus.isLimited) {
          photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted && !photosStatus.isLimited) {
            _logger.warning('Permiso de galería denegado');
            return null;
          }
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

  /// Muestra una hoja inferior que permite al usuario elegir entre la galería y
  /// la cámara, luego llama a [onImagePicked] con el [XFile] resultante.
  ///
  /// La opción de cámara está oculta en la web y en las plataformas de escritorio. Si la cámara
  /// devuelve `null` (por ejemplo, permiso denegado), se muestra un error de snack-bar.
  ///
  /// [context] El [BuildContext] utilizado para mostrar la hoja modal.
  /// [onImagePicked] Callback invocado con el archivo seleccionado, o `null` si el
  /// usuario canceló o ocurrió un error.
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
