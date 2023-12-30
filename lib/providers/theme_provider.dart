import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {

  bool _isLightMode = false;
  bool get isLightMode => _isLightMode;

  void toggleTheme(){
    _isLightMode = !_isLightMode;
    notifyListeners();
  }
}
