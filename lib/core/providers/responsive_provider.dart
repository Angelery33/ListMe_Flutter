import 'package:flutter/widgets.dart';

/// Puntos de interrupción adaptativos de Material 3.
///
/// compact  < 600dp  — móvil en vertical, ventana estrecha
/// medium   600–840  — móvil en horizontal, tablet en vertical
/// expanded > 840dp  — tablet en horizontal, escritorio
enum Breakpoint { compact, medium, expanded }

/// [ChangeNotifier] que rastrea el tamaño de pantalla lógico y expone
/// valores de diseño conscientes del punto de interrupción utilizados en toda la aplicación.
///
/// Se registra como un [WidgetsBindingObserver] para que se actualice automáticamente
/// siempre que cambien las métricas de la ventana/dispositivo (rotación, cambio de tamaño, etc.).
class ResponsiveProvider extends ChangeNotifier with WidgetsBindingObserver {
  double _width = 0;
  double _height = 0;

  /// Crea el proveedor y comienza a escuchar los cambios en las métricas de la plataforma.
  ResponsiveProvider() {
    WidgetsBinding.instance.addObserver(this);
    _updateSize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => _updateSize();

  void _updateSize() {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return;
    final size = view.physicalSize / view.devicePixelRatio;
    if (size.width == _width && size.height == _height) return;
    _width = size.width;
    _height = size.height;
    notifyListeners();
  }

  // ── Dimensiones en bruto ─────────────────────────────────────────────────

  /// Ancho de pantalla lógico actual en píxeles independientes de la densidad.
  double get screenWidth => _width;

  /// Altura de pantalla lógico actual en píxeles independientes de la densidad.
  double get screenHeight => _height;

  // ── Breakpoint ────────────────────────────────────────────────────────────

  /// [Breakpoint] activo derivado de [screenWidth].
  Breakpoint get breakpoint {
    if (_width < 600) return Breakpoint.compact;
    if (_width < 840) return Breakpoint.medium;
    return Breakpoint.expanded;
  }

  /// `true` cuando el ancho de la pantalla está por debajo de 600 dp (móvil en vertical).
  bool get isCompact  => breakpoint == Breakpoint.compact;

  /// `true` cuando el ancho de la pantalla está entre 600 y 840 dp.
  bool get isMedium   => breakpoint == Breakpoint.medium;

  /// `true` cuando el ancho de la pantalla supera los 840 dp (tablet/escritorio).
  bool get isExpanded => breakpoint == Breakpoint.expanded;

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Utiliza un NavigationRail lateral en lugar de una NavigationBar inferior.
  bool get useSideNav => !isCompact;

  // ── Columnas de cuadrícula (cuadrícula compacta en ListScreen) ───────────

  /// Número de columnas para la cuadrícula de tarjetas compactas, escalado por punto de interrupción.
  int get compactGridColumns {
    switch (breakpoint) {
      case Breakpoint.compact:  return 3;
      case Breakpoint.medium:   return 4;
      case Breakpoint.expanded: return 6;
    }
  }

  // ── Columnas de lista (vista estándar multi-columna en pantallas anchas) ──

  /// Número de columnas al renderizar elementos como una lista estándar en pantallas anchas.
  int get listColumns {
    switch (breakpoint) {
      case Breakpoint.compact:  return 1;
      case Breakpoint.medium:   return 2;
      case Breakpoint.expanded: return 3;
    }
  }

  // ── Ancho máximo de contenido para layouts expanded ─────────────────────

  /// Ancho máximo de contenido para evitar diseños excesivamente anchos en pantallas grandes.
  double get maxContentWidth {
    switch (breakpoint) {
      case Breakpoint.compact:  return double.infinity;
      case Breakpoint.medium:   return 780;
      case Breakpoint.expanded: return 1280;
    }
  }

  /// Ancho máximo para pantallas de formulario de una sola columna (entrada, configuración).
  double get formMaxWidth {
    switch (breakpoint) {
      case Breakpoint.compact:  return double.infinity;
      case Breakpoint.medium:   return 700;
      case Breakpoint.expanded: return 800;
    }
  }

  // ── Padding ───────────────────────────────────────────────────────────────

  /// Relleno de contenido horizontal apropiado para el punto de interrupción actual.
  double get horizontalPadding {
    switch (breakpoint) {
      case Breakpoint.compact:  return 12;
      case Breakpoint.medium:   return 24;
      case Breakpoint.expanded: return 32;
    }
  }

  // ── Dimensiones de tarjeta activa (scroll horizontal en ActiveItemsSection) ─

  /// Ancho de una tarjeta de elemento activo en la sección de desplazamiento horizontal.
  double get activeCardWidth {
    switch (breakpoint) {
      case Breakpoint.compact:  return 130;
      case Breakpoint.medium:   return 160;
      case Breakpoint.expanded: return 190;
    }
  }

  /// Altura de una tarjeta de elemento activo en la sección de desplazamiento horizontal.
  double get activeCardHeight {
    switch (breakpoint) {
      case Breakpoint.compact:  return 180;
      case Breakpoint.medium:   return 210;
      case Breakpoint.expanded: return 240;
    }
  }

  // ── Tamaño de fuente del encabezado de sección ──────────────────────────

  /// Tamaño de fuente utilizado para las etiquetas de encabezado de grupo/sección.
  double get sectionHeaderFontSize {
    switch (breakpoint) {
      case Breakpoint.compact:  return 12;
      case Breakpoint.medium:   return 13;
      case Breakpoint.expanded: return 14;
    }
  }

  // ── Tamaño de fuente de chips de etiqueta (DetailHeaderTags) ────────────

  /// Tamaño de fuente utilizado para los chips de etiquetas de metadatos en los encabezados de detalles de los elementos.
  double get tagFontSize {
    switch (breakpoint) {
      case Breakpoint.compact:  return 10;
      case Breakpoint.medium:   return 11;
      case Breakpoint.expanded: return 12;
    }
  }

  // ── Tamaño de icono en chips de etiqueta ─────────────────────────────────

  /// Tamaño de icono utilizado dentro de los chips de etiquetas de metadatos.
  double get tagIconSize {
    switch (breakpoint) {
      case Breakpoint.compact:  return 12;
      case Breakpoint.medium:   return 14;
      case Breakpoint.expanded: return 16;
    }
  }
}
