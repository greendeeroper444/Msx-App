import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier([ThemeData? themeData]) : _themeData = themeData ?? ThemeData.dark() {
    // Provide a default value if themeData is null
    _themeData ??= ThemeData.dark();
  }

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  static ThemeNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedThemeNotifier>()?.themeNotifier ?? ThemeNotifier();
  }
}

class _InheritedThemeNotifier extends InheritedWidget {
  final ThemeNotifier themeNotifier;

  _InheritedThemeNotifier({
    Key? key,
    required Widget child,
    required this.themeNotifier,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
