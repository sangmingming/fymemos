import 'package:flutter/foundation.dart';
import 'package:fymemos/config/refena.dart';
import 'package:fymemos/ui/core/theme/dynamic_colors.dart';
import 'package:refena_flutter/refena_flutter.dart';

Future<RefenaContainer> preinit(List<String> args) async {
  final dynamicColors = await getDynamicColors();

  final container = RefenaContainer(
    observers: kDebugMode ? [CustomRefenaObserver()] : [],
    overrides: [dynamicColorsProvider.overrideWithValue(dynamicColors)],
  );

  return container;
}
