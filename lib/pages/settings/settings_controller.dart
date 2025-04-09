import 'package:fymemos/data/services/settings_provider.dart';
import 'package:fymemos/pages/settings/setting_vm.dart';
import 'package:fymemos/ui/core/theme/color_mode.dart';
import 'package:fymemos/ui/core/theme/dynamic_colors.dart';
import 'package:refena_flutter/refena_flutter.dart';

final settingsControllerProvider = ReduxProvider<SettingsController, SettingVM>(
  (ref) {
    final settings = ref.notifier(settingsProvider);
    final supportsDynamicColors = ref.read(dynamicColorsProvider) != null;
    return SettingsController(
      settingsService: settings,
      supportsDynamicColors: supportsDynamicColors,
    );
  },
);

class SettingsController extends ReduxNotifier<SettingVM> {
  final SettingsService _settingsService;

  final bool _supportsDynamicColors;

  SettingsController({
    required SettingsService settingsService,
    required bool supportsDynamicColors,
  }) : this._settingsService = settingsService,
       this._supportsDynamicColors = supportsDynamicColors;

  @override
  SettingVM init() {
    return SettingVM(
      settings: _settingsService.state,
      colorModes:
          _supportsDynamicColors
              ? ColorMode.values
              : ColorMode.values
                  .where((color) => color != ColorMode.system)
                  .toList(),
      onChangeTheme: (context, theme) async {
        _settingsService.setTheme(theme);
      },
      onChangeColorMode: (context, colorMode) async {
        await _settingsService.setColorMode(colorMode);
      },
    );
  }

  @override
  BaseReduxAction<ReduxNotifier<SettingVM>, SettingVM, dynamic>?
  get initialAction => _SettingsInitAction();
}

class _SettingsInitAction extends WatchAction<SettingsController, SettingVM> {
  @override
  SettingVM reduce() {
    return state.copyWith(settings: ref.watch(settingsProvider));
  }
}
