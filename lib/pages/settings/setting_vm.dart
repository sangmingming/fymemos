import 'package:flutter/material.dart';
import 'package:fymemos/model/settings_state.dart';
import 'package:fymemos/ui/core/theme/color_mode.dart';

class SettingVM {
  final SettingsState settings;
  final List<ThemeMode> themeModes = ThemeMode.values;
  final List<ColorMode> colorModes;

  final void Function(BuildContext context, ThemeMode mode) onChangeTheme;

  final void Function(BuildContext context, ColorMode mode) onChangeColorMode;

  SettingVM({
    required this.settings,
    required this.colorModes,
    required this.onChangeTheme,
    required this.onChangeColorMode,
  });

  SettingVM copyWith({
    SettingsState? settings,
    void Function(BuildContext context, ThemeMode mode)? onChangeTheme,
    void Function(BuildContext context, ColorMode mode)? onChangeColorMode,
  }) {
    return SettingVM(
      settings: settings ?? this.settings,
      colorModes: colorModes,
      onChangeTheme: onChangeTheme ?? this.onChangeTheme,
      onChangeColorMode: onChangeColorMode ?? this.onChangeColorMode,
    );
  }
}
