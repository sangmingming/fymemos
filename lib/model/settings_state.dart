import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;

  SettingsState({this.themeMode = ThemeMode.system});

  SettingsState copyWith({ThemeMode? themeMode}) {
    return SettingsState(themeMode: themeMode ?? this.themeMode);
  }
}
