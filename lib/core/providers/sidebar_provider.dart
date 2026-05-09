import 'package:flutter/material.dart';

class SidebarProvider extends ChangeNotifier {
  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void setExpanded(bool value) {
    if (_isExpanded != value) {
      _isExpanded = value;
      notifyListeners();
    }
  }
}
