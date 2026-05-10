import 'package:flutter/widgets.dart';

/// Material 3 adaptive breakpoints.
///
/// compact  < 600dp  — phone portrait, narrow browser window
/// medium   600–840  — phone landscape, tablet portrait, iPhone in browser
/// expanded > 840dp  — tablet landscape, desktop, wide browser window
enum Breakpoint { compact, medium, expanded }

class ResponsiveProvider extends ChangeNotifier with WidgetsBindingObserver {
  double _width = 0;
  double _height = 0;

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
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    if (size.width == _width && size.height == _height) return;
    _width = size.width;
    _height = size.height;
    notifyListeners();
  }

  // ── Raw dimensions ────────────────────────────────────────────────────────
  double get screenWidth => _width;
  double get screenHeight => _height;

  // ── Breakpoint ────────────────────────────────────────────────────────────
  Breakpoint get breakpoint {
    if (_width < 600) return Breakpoint.compact;
    if (_width < 840) return Breakpoint.medium;
    return Breakpoint.expanded;
  }

  bool get isCompact  => breakpoint == Breakpoint.compact;
  bool get isMedium   => breakpoint == Breakpoint.medium;
  bool get isExpanded => breakpoint == Breakpoint.expanded;

  // ── Navigation ────────────────────────────────────────────────────────────
  /// Use a side NavigationRail instead of a bottom NavigationBar.
  bool get useSideNav => !isCompact;

  // ── Grid columns (compact card grid in ListScreen) ────────────────────────
  int get compactGridColumns {
    switch (breakpoint) {
      case Breakpoint.compact:  return 3;
      case Breakpoint.medium:   return 4;
      case Breakpoint.expanded: return 6;
    }
  }

  // ── List columns (standard list view shown as multi-column on wide screens) ─
  int get listColumns {
    switch (breakpoint) {
      case Breakpoint.compact:  return 1;
      case Breakpoint.medium:   return 2;
      case Breakpoint.expanded: return 3;
    }
  }

  // ── Content width cap for expanded layouts ────────────────────────────────
  double get maxContentWidth {
    switch (breakpoint) {
      case Breakpoint.compact:  return double.infinity;
      case Breakpoint.medium:   return 780;
      case Breakpoint.expanded: return 1280;
    }
  }

  /// Max width for single-column form screens (entry, config).
  double get formMaxWidth {
    switch (breakpoint) {
      case Breakpoint.compact:  return double.infinity;
      case Breakpoint.medium:   return 700;
      case Breakpoint.expanded: return 800;
    }
  }

  // ── Padding ───────────────────────────────────────────────────────────────
  double get horizontalPadding {
    switch (breakpoint) {
      case Breakpoint.compact:  return 12;
      case Breakpoint.medium:   return 24;
      case Breakpoint.expanded: return 32;
    }
  }

  // ── Card item dimensions (ActiveItemsSection horizontal scroll) ─────────
  double get activeCardWidth {
    switch (breakpoint) {
      case Breakpoint.compact:  return 130;
      case Breakpoint.medium:   return 160;
      case Breakpoint.expanded: return 190;
    }
  }

  double get activeCardHeight {
    switch (breakpoint) {
      case Breakpoint.compact:  return 180;
      case Breakpoint.medium:   return 210;
      case Breakpoint.expanded: return 240;
    }
  }

  // ── Section header font size ─────────────────────────────────────────────
  double get sectionHeaderFontSize {
    switch (breakpoint) {
      case Breakpoint.compact:  return 12;
      case Breakpoint.medium:   return 13;
      case Breakpoint.expanded: return 14;
    }
  }

  // ── Tag font size (DetailHeaderTags) ──────────────────────────────────────
  double get tagFontSize {
    switch (breakpoint) {
      case Breakpoint.compact:  return 10;
      case Breakpoint.medium:   return 11;
      case Breakpoint.expanded: return 12;
    }
  }

  // ── Tag icon size ────────────────────────────────────────────────────────
  double get tagIconSize {
    switch (breakpoint) {
      case Breakpoint.compact:  return 12;
      case Breakpoint.medium:   return 14;
      case Breakpoint.expanded: return 16;
    }
  }
}
