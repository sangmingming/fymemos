import 'package:flutter/material.dart';
import 'package:fymemos/ui/core/theme/color_mode.dart';

class SettingsState {
  final ThemeMode themeMode;
  final ColorMode colorMode;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.colorMode = ColorMode.system,
  });

  SettingsState copyWith({ThemeMode? themeMode, ColorMode? colorMode}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      colorMode: colorMode ?? this.colorMode,
    );
  }
}
