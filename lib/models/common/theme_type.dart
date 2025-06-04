import 'package:flutter/material.dart';

enum ThemeType {
  light,
  dark,
  system,
}

extension ThemeTypeDesc on ThemeType {
  String get description => ['Light', 'Dark', 'System'][index];
}

extension ThemeTypeCode on ThemeType {
  int get code => [0, 1, 2][index];
}

extension ThemeTypeToThemeMode on ThemeType {
  ThemeMode get toThemeMode => [ThemeMode.light, ThemeMode.dark, ThemeMode.system][index];
}
