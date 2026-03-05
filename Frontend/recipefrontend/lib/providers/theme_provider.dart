import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.forestGreen;

  AppTheme get currentTheme => _currentTheme;
  ThemeData get themeData => AppThemes.buildTheme(_currentTheme);

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_index') ?? 0;
    _currentTheme = AppTheme.values[index];
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', theme.index);
    notifyListeners();
  }
}
