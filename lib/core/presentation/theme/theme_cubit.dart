import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode');
    final color = prefs.getInt('mainColor');
    emit(ThemeState(
      themeMode: isDark == null
          ? ThemeMode.system
          : (isDark ? ThemeMode.dark : ThemeMode.light),
      mainColor: color ?? 0xFF00BCD4,
    ));
  }

  Future<void> changeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', mode == ThemeMode.dark);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> changeMainColor(int color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mainColor', color);
    emit(state.copyWith(mainColor: color));
  }
}
