import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeKey = 'APP_THEME_MODE';

  ThemeCubit() : super(_loadTheme());

  static ThemeMode _loadTheme() {
    final isDark = StorageService.getBool(_themeKey) ?? true;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    final newTheme = isDark ? ThemeMode.light : ThemeMode.dark;
    StorageService.setBool(_themeKey, !isDark);
    emit(newTheme);
  }

  void setDarkTheme(bool isDark) {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    StorageService.setBool(_themeKey, isDark);
    emit(newTheme);
  }
}
