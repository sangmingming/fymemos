import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:fymemos/model/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = NotifierProvider<SettingsService, SettingsState>((
  ref,
) {
  final sp = SharedPreferencesAsync();
  return SettingsService(sp);
});

class SettingsService extends PureNotifier<SettingsState> {
  final SharedPreferencesAsync _sharedPreferences;

  SettingsService(this._sharedPreferences);

  @override
  SettingsState init() => SettingsState(themeMode: _themeMode);

  Future<void> setTheme(ThemeMode mode) async {
    await _sharedPreferences.setString('themeMode', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  ThemeMode get _themeMode {
    final mode = _sharedPreferences.getString('themeMode');
    if (mode == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhereOrNull((theme) => theme.name == mode) ??
        ThemeMode.system;
  }
}
