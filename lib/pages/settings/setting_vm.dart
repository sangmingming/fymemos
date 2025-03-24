import 'package:flutter/material.dart';
import 'package:fymemos/model/settings_state.dart';

class SettingVM {
  final SettingsState settings;
  final List<ThemeMode> themeModes = ThemeMode.values;

  final void Function(BuildContext context, ThemeMode mode) onChangeTheme;

  SettingVM({required this.settings, required this.onChangeTheme});

  SettingVM copyWith({
    SettingsState? settings,
    void Function(BuildContext context, ThemeMode mode)? onChangeTheme,
  }) {
    return SettingVM(
      settings: settings ?? this.settings,
      onChangeTheme: onChangeTheme ?? this.onChangeTheme,
    );
  }
}
