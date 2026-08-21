import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final int mainColor;
  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.mainColor = 0xFF00BCD4,
  });

  ThemeState copyWith({ThemeMode? themeMode, int? mainColor}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      mainColor: mainColor ?? this.mainColor,
    );
  }
}
