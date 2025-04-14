import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fymemos/ui/core/theme/color_mode.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:fymemos/model/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = NotifierProvider<SettingsService, SettingsState>((
  ref,
) {
  final sp = SharedPreferencesAsync();
  return SettingsService(sp)..initSettings();
});

class SettingsService extends PureNotifier<SettingsState> {
  final SharedPreferencesAsync _sharedPreferences;

  SettingsService(this._sharedPreferences);

  @override
  SettingsState init() => SettingsState();

  void initSettings() async {
    final color = await _getColorMode();
    final theme = await _getThemeMode();
    state = state.copyWith(themeMode: theme, colorMode: color);
  }

  Future<ColorMode> _getColorMode() async {
    final mode = await _sharedPreferences.getString('colorMode');
    if (mode == null) {
      return ColorMode.system;
    }
    return ColorMode.values.firstWhereOrNull((color) => color.name == mode) ??
        ColorMode.system;
  }

  Future<ThemeMode> _getThemeMode() async {
    final mode = await _sharedPreferences.getString('themeMode');
    if (mode == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhereOrNull((theme) => theme.name == mode) ??
        ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _sharedPreferences.setString('themeMode', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setColorMode(ColorMode mode) async {
    await _sharedPreferences.setString('colorMode', mode.name);
    state = state.copyWith(colorMode: mode);
  }
}
