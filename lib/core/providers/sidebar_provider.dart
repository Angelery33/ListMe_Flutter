import 'package:flutter/material.dart';

/// [ChangeNotifier] que controla si el riel de navegación lateral está expandido
/// o colapsado en los puntos de interrupción medio/expandido.
///
/// Los widgets que renderizan la barra lateral observan este proveedor para animar entre los
/// estados ancho (etiqueta visible) y estrecho (solo icono).
class SidebarProvider extends ChangeNotifier {
  bool _isExpanded = true;

  /// Indica si la barra lateral está actualmente en su estado expandido (ancho).
  bool get isExpanded => _isExpanded;

  /// Alterna la barra lateral entre los estados expandido y colapsado y notifica a los
  /// oyentes para que la IU pueda animar la transición.
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// Establece la barra lateral en un [value] específico y notifica a los oyentes solo cuando
  /// el estado cambia realmente, evitando reconstrucciones innecesarias.
  ///
  /// [value] `true` to expand, `false` to collapse.
  void setExpanded(bool value) {
    if (_isExpanded != value) {
      _isExpanded = value;
      notifyListeners();
    }
  }
}
