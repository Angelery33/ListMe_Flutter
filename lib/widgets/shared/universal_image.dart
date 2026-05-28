import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget de imagen multiplataforma que resuelve la mejor URL disponible de
/// múltiples fuentes y la renderiza correctamente en web y nativo.
///
/// Prioridad de fuente (de mayor a menor):
/// 1. Punto de conexión de imagen de la API cuando se proporcionan tanto [itemId] como [imageId] —
///    evita problemas de CORS al enrutar a través del backend.
/// 2. [remoteImageUrl] — una URL remota directa, funciona en todos los dispositivos y plataformas.
/// 3. Prefijo `blob:` en [imagePath] — un blob del selector de imágenes web antes de la subida.
/// 4. Ruta de archivo local en [imagePath] — solo válida en el dispositivo nativo de origen.
///
/// En la web, las URL de Firebase Storage se obtienen a través del SDK para omitir las
/// restricciones de CORS, con un caché en memoria por sesión para evitar extracciones repetidas.
class UniversalImage extends StatelessWidget {
  /// Ruta de archivo local, URL de blob (web) o cualquier URL restante no cubierta por los
  /// otros campos. Se evalúa en último lugar en la cadena de prioridad de resolución.
  final String imagePath;

  /// URL remota directa opcional (CDN, MAL, etc.). Se prefiere sobre [imagePath]
  /// cuando está presente.
  final String? remoteImageUrl;

  /// Cómo debe inscribirse la imagen en el cuadro asignado.
  final BoxFit fit;

  /// Ancho explícito opcional en píxeles lógicos.
  final double? width;

  /// Altura explícita opcional en píxeles lógicos.
  final double? height;

  /// El ID del elemento al que pertenece la imagen. Cuando se combina con [imageId],
  /// el widget construye una URL de la API del backend que evita problemas de CORS.
  final int? itemId;

  /// El ID del registro de imagen en el backend. Se utiliza junto con [itemId].
  final int? imageId;

  const UniversalImage(
    this.imagePath, {
    super.key,
    this.remoteImageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.itemId,
    this.imageId,
  });

  @override
  Widget build(BuildContext context) {
    final url = _getBestUrl();

    if (url.isEmpty) return _placeholder(context);

    // En web, las URLs de Firebase Storage deben pasar por el SDK para evitar CORS
    if (kIsWeb && _isFirebaseStorageUrl(url)) {
      return _WebFirebaseImage(
        url: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: _placeholder(context),
      );
    }

    if (url.startsWith('http') || url.startsWith('blob:')) {
      final displayUrl = _proxyUrl(url);
      return Image.network(
        displayUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    // Archivo local — solo válido en móvil, en el mismo dispositivo donde se seleccionó
    if (kIsWeb) return _placeholder(context);

    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, fit: fit, width: width, height: height);
    }
    return _placeholder(context);
  }

  /// Selecciona la URL disponible de mayor prioridad según las reglas de resolución.
  String _getBestUrl() {
    // Si tenemos itemId e imageId, usar el endpoint de la API (evita problemas de CORS)
    if (itemId != null && imageId != null) {
      return 'https://api.angelcantero.store/api/v1/images/$itemId/$imageId';
    }

    // URL remota como fallback (funciona en todos los dispositivos y plataformas)
    if (remoteImageUrl?.isNotEmpty == true) return remoteImageUrl!;

    // URL blob del selector de imágenes web (antes de subir)
    if (imagePath.isNotEmpty && imagePath.startsWith('blob:')) return imagePath;

    // Las rutas locales solo son válidas en el mismo dispositivo donde se seleccionaron
    if (kIsWeb) return '';

    // Ruta local o cualquier URL restante (p.ej. imagen de MAL pasada directamente como imagePath)
    if (imagePath.isNotEmpty) return imagePath;

    return '';
  }

  /// Devuelve `true` cuando [url] apunta a un bucket de Firebase Storage.
  bool _isFirebaseStorageUrl(String url) =>
      url.contains('firebasestorage.googleapis.com');

  static const _backendProxyBase =
      'https://api.angelcantero.store/api/v1/proxy/image?url=';
  static const _weservBase = 'https://images.weserv.nl/?url=';

  /// En la web, envuelve [url] en un proxy para solucionar las restricciones de CORS.
  ///
  /// - Las URL de Firebase Storage se devuelven tal cual (manejadas por la ruta del SDK anterior).
  /// - Las imágenes de la CDN de MyAnimeList se envían a través del propio backend de la aplicación porque
  ///   weserv.nl no puede acceder a ellas.
  /// - Todas las demás URL remotas se envían a través de weserv.nl.
  /// - En nativo, la URL original se devuelve sin cambios.
  String _proxyUrl(String url) {
    if (!kIsWeb) return url;
    if (_isFirebaseStorageUrl(url)) return url;
    if (url.contains('images.weserv.nl') || url.contains('angelcantero.store')) return url;
    // Imágenes de MAL: proxy a través del backend propio (weserv.nl no puede acceder a la CDN de MAL)
    if (url.contains('myanimelist.net')) {
      return '$_backendProxyBase${Uri.encodeComponent(url)}';
    }
    // Todo lo demás en web: weserv.nl para CORS
    return '$_weservBase${Uri.encodeComponent(url)}';
  }

  /// Construye el marcador de posición de respaldo que se muestra cuando no se puede cargar ninguna imagen.
  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.outline,
          size: 40,
        ),
      ),
    );
  }
}

/// Caché en memoria para que cada URL de Firebase Storage solo se obtenga una vez por sesión.
final Map<String, Uint8List> _firebaseImageCache = {};

/// Obtiene una imagen de Firebase Storage a través del SDK (necesario en la web para omitir CORS)
/// y la renderiza a partir de bytes en memoria una vez cargada.
///
/// Muestra un indicador de carga mientras la descarga está en curso, y recurre a
/// [placeholder] si la descarga falla o no devuelve datos.
class _WebFirebaseImage extends StatefulWidget {
  /// La URL de descarga de Firebase Storage.
  final String url;

  /// Cómo la imagen decodificada debe llenar el cuadro asignado.
  final BoxFit fit;

  /// Ancho explícito opcional.
  final double? width;

  /// Altura explícita opcional.
  final double? height;

  /// Widget que se muestra cuando la imagen no se carga o los datos no están disponibles.
  final Widget placeholder;

  const _WebFirebaseImage({
    required this.url,
    required this.fit,
    this.width,
    this.height,
    required this.placeholder,
  });

  @override
  State<_WebFirebaseImage> createState() => _WebFirebaseImageState();
}

/// Estado para [_WebFirebaseImage].
///
/// Gestiona el ciclo de vida de la descarga asíncrona y el almacenamiento en caché de los bytes de imagen sin procesar.
class _WebFirebaseImageState extends State<_WebFirebaseImage> {
  /// Los bytes de la imagen descargada, o `null` mientras se carga o en caso de fallo.
  Uint8List? _bytes;

  /// Indica si la descarga todavía está en curso.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Descarga la imagen de Firebase Storage y almacena los bytes en el
  /// [_firebaseImageCache] en memoria para renderizados posteriores.
  Future<void> _load() async {
    // Servir desde caché si está disponible
    if (_firebaseImageCache.containsKey(widget.url)) {
      if (mounted) {
        setState(() {
          _bytes = _firebaseImageCache[widget.url];
          _loading = false;
        });
      }
      return;
    }

    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.url);
      final bytes = await ref.getData(10 * 1024 * 1024); // 10 MB max
      if (bytes != null) {
        _firebaseImageCache[widget.url] = bytes;
        if (mounted) setState(() { _bytes = bytes; _loading = false; });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (_bytes == null) return widget.placeholder;
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) => widget.placeholder,
    );
  }
}
