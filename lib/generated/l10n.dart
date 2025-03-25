// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Memo`
  String get title_memo {
    return Intl.message('Memo', name: 'title_memo', desc: '', args: []);
  }

  /// `Settings`
  String get title_settings {
    return Intl.message('Settings', name: 'title_settings', desc: '', args: []);
  }

  /// `Archived`
  String get title_archived {
    return Intl.message('Archived', name: 'title_archived', desc: '', args: []);
  }

  /// `Resources`
  String get title_resources {
    return Intl.message(
      'Resources',
      name: 'title_resources',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get title_about {
    return Intl.message('About', name: 'title_about', desc: '', args: []);
  }

  /// `{count, plural, =0{Day} =1{Day} other{Days}}`
  String memo_days(num count) {
    return Intl.plural(
      count,
      zero: 'Day',
      one: 'Day',
      other: 'Days',
      name: 'memo_days',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =0{Tag} =1{Tag} other{Tags}}`
  String memo_tags(num count) {
    return Intl.plural(
      count,
      zero: 'Tag',
      one: 'Tag',
      other: 'Tags',
      name: 'memo_tags',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =0{Memo} =1{Memo} other{Memos}}`
  String memo_memos(num count) {
    return Intl.plural(
      count,
      zero: 'Memo',
      one: 'Memo',
      other: 'Memos',
      name: 'memo_memos',
      desc: '',
      args: [count],
    );
  }

  /// `Rename`
  String get edit_rename {
    return Intl.message('Rename', name: 'edit_rename', desc: '', args: []);
  }

  /// `Delete`
  String get edit_delete {
    return Intl.message('Delete', name: 'edit_delete', desc: '', args: []);
  }

  /// `Archive`
  String get edit_archive {
    return Intl.message('Archive', name: 'edit_archive', desc: '', args: []);
  }

  /// `Pin`
  String get edit_pin {
    return Intl.message('Pin', name: 'edit_pin', desc: '', args: []);
  }

  /// `Restore`
  String get edit_restore {
    return Intl.message('Restore', name: 'edit_restore', desc: '', args: []);
  }

  /// `Unpin`
  String get edit_Unpin {
    return Intl.message('Unpin', name: 'edit_Unpin', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Login`
  String get title_login {
    return Intl.message('Login', name: 'title_login', desc: '', args: []);
  }

  /// `Save`
  String get button_save {
    return Intl.message('Save', name: 'button_save', desc: '', args: []);
  }

  /// `Cancel`
  String get button_cancel {
    return Intl.message('Cancel', name: 'button_cancel', desc: '', args: []);
  }

  /// `Login`
  String get button_login {
    return Intl.message('Login', name: 'button_login', desc: '', args: []);
  }

  /// `Logout`
  String get button_logout {
    return Intl.message('Logout', name: 'button_logout', desc: '', args: []);
  }

  /// `Theme Mode`
  String get title_theme {
    return Intl.message('Theme Mode', name: 'title_theme', desc: '', args: []);
  }

  /// `System`
  String get theme_system {
    return Intl.message('System', name: 'theme_system', desc: '', args: []);
  }

  /// `Light`
  String get theme_light {
    return Intl.message('Light', name: 'theme_light', desc: '', args: []);
  }

  /// `Dark`
  String get theme_dark {
    return Intl.message('Dark', name: 'theme_dark', desc: '', args: []);
  }

  /// `Home`
  String get title_home {
    return Intl.message('Home', name: 'title_home', desc: '', args: []);
  }

  /// `Search Memos...`
  String get hint_search {
    return Intl.message(
      'Search Memos...',
      name: 'hint_search',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this memo? THIS ACTION IS IRREVERSIBLE`
  String get delete_memo_confirm {
    return Intl.message(
      'Are you sure you want to delete this memo? THIS ACTION IS IRREVERSIBLE',
      name: 'delete_memo_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete Tag`
  String get title_delete_tag {
    return Intl.message(
      'Delete Tag',
      name: 'title_delete_tag',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this tag? This will remove all memos related to #{tag}.`
  String delete_tag_confirm(String tag) {
    return Intl.message(
      'Are you sure you want to delete this tag? This will remove all memos related to #$tag.',
      name: 'delete_tag_confirm',
      desc: 'A message with a single parameter',
      args: [tag],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
