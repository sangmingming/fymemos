import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fymemos/ui/core/theme/color_mode.dart';
import 'package:fymemos/ui/core/theme/dynamic_colors.dart';
import 'package:fymemos/utils/platform_check.dart';

double get desktopPaddingFix => checkPlatformIsDesktop() ? 8 : 0;

ThemeData getTheme(
  Brightness brightness,
  DynamicColors? dynamicColors, [
  ColorMode colorMode = ColorMode.system,
]) {
  final colorScheme = _determineColorScheme(
    brightness,
    dynamicColors,
    colorMode,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    navigationBarTheme:
        colorScheme.brightness == Brightness.dark
            ? NavigationBarThemeData(
              iconTheme: WidgetStateProperty.all(
                const IconThemeData(color: Colors.white),
              ),
            )
            : null,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor:
            colorScheme.brightness == Brightness.dark ? Colors.white : null,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8 + desktopPaddingFix,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8 + desktopPaddingFix,
        ),
      ),
    ),
    //   fontFamily: "Noto",
  );
}

ColorScheme _determineColorScheme(
  Brightness brightness,
  DynamicColors? dynamicColors, [
  ColorMode colorMode = ColorMode.system,
]) {
  final defaultColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: brightness,
  );
  if (colorMode == ColorMode.system) {
    final colorScheme =
        brightness == Brightness.light
            ? dynamicColors?.light
            : dynamicColors?.dark;
    return colorScheme ?? defaultColorScheme;
  }
  return ColorScheme.fromSeed(
    seedColor: colorMode.color,
    brightness: brightness,
  );
}

Future<void> updateSystemOverlayStyle(BuildContext context) async {
  final brightness = Theme.of(context).brightness;
  await updateSystemOverlayStyleWithBrightness(brightness);
}

Future<void> updateSystemOverlayStyleWithBrightness(
  Brightness brightness,
) async {
  if (checkPlatform([TargetPlatform.android])) {
    final darkMode = brightness == Brightness.dark;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final androidSdkInt = androidInfo.version.sdkInt;
    final bool edgeToEdge = androidSdkInt >= 29;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    ); // ignore: unawaited_futures

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            edgeToEdge
                ? Colors.transparent
                : (darkMode ? Colors.black : Colors.white),
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness:
            darkMode ? Brightness.light : Brightness.dark,
      ),
    );
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness, // iOS
        statusBarColor: Colors.transparent, // Not relevant to this issue
      ),
    );
  }
}
