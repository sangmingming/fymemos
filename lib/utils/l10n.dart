import 'package:flutter/material.dart';
import 'package:fymemos/generated/l10n.dart';

extension L10nExtension on BuildContext {
  S get intl => S.of(this);
}

extension L10nExtension2 on S {
  String operator [](String key) {
    switch (key) {
      case 'title_home':
        return title_home;
      case 'title_archived':
        return title_archived;
      case 'title_resources':
        return title_resources;
      // 添加其他 key 的 case
      default:
        throw FlutterError('Localization key "$key" not support [] load');
    }
  }
}
