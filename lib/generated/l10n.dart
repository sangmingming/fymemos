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

  /// `Public`
  String get visibility_public {
    return Intl.message(
      'Public',
      name: 'visibility_public',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get visibility_private {
    return Intl.message(
      'Private',
      name: 'visibility_private',
      desc: '',
      args: [],
    );
  }

  /// `Workspace`
  String get visibility_workspace {
    return Intl.message(
      'Workspace',
      name: 'visibility_workspace',
      desc: '',
      args: [],
    );
  }

  /// `Referencing 1 memo: {snippet}`
  String memo_reference_one(String snippet) {
    return Intl.message(
      'Referencing 1 memo: $snippet',
      name: 'memo_reference_one',
      desc: 'A message with a single parameter',
      args: [snippet],
    );
  }

  /// `Referenced by 1 memo: {snippet}`
  String memo_reference_by_one(String snippet) {
    return Intl.message(
      'Referenced by 1 memo: $snippet',
      name: 'memo_reference_by_one',
      desc: 'A message with a single parameter',
      args: [snippet],
    );
  }

  /// `{count, plural, =0{Referencing with 0 memo} =1{Referencing with 1 memo} other{Referencing with {count} memos}}`
  String memo_references(num count) {
    return Intl.plural(
      count,
      zero: 'Referencing with 0 memo',
      one: 'Referencing with 1 memo',
      other: 'Referencing with $count memos',
      name: 'memo_references',
      desc: '',
      args: [count],
    );
  }

  /// `Memo Detail`
  String get memo_title_detail {
    return Intl.message(
      'Memo Detail',
      name: 'memo_title_detail',
      desc: '',
      args: [],
    );
  }

  /// `Rename Tag`
  String get title_rename_tag {
    return Intl.message(
      'Rename Tag',
      name: 'title_rename_tag',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get button_finish {
    return Intl.message('Finish', name: 'button_finish', desc: '', args: []);
  }

  /// `New tag name`
  String get hint_new_tag {
    return Intl.message(
      'New tag name',
      name: 'hint_new_tag',
      desc: '',
      args: [],
    );
  }

  /// `Tag renamed`
  String get msg_tag_rename {
    return Intl.message(
      'Tag renamed',
      name: 'msg_tag_rename',
      desc: '',
      args: [],
    );
  }

  /// `Tag deleted`
  String get msg_tag_delete {
    return Intl.message(
      'Tag deleted',
      name: 'msg_tag_delete',
      desc: '',
      args: [],
    );
  }

  /// `Now`
  String get time_now {
    return Intl.message('Now', name: 'time_now', desc: '', args: []);
  }

  /// `{minutes, plural, =0{Now} =1{1 minute ago} other{{minutes} minutes ago}}`
  String time_minutes_ago(num minutes) {
    return Intl.plural(
      minutes,
      zero: 'Now',
      one: '1 minute ago',
      other: '$minutes minutes ago',
      name: 'time_minutes_ago',
      desc: '',
      args: [minutes],
    );
  }

  /// `{hours, plural, =0{Now} =1{1 hour ago} other{{hours} hours ago}}`
  String time_hours_ago(num hours) {
    return Intl.plural(
      hours,
      zero: 'Now',
      one: '1 hour ago',
      other: '$hours hours ago',
      name: 'time_hours_ago',
      desc: '',
      args: [hours],
    );
  }

  /// `{days, plural, =0{Now} =1{Yesterday} other{{days} days ago}}`
  String time_days_ago(num days) {
    return Intl.plural(
      days,
      zero: 'Now',
      one: 'Yesterday',
      other: '$days days ago',
      name: 'time_days_ago',
      desc: '',
      args: [days],
    );
  }

  /// `Login with Access Token`
  String get login_type_access_token {
    return Intl.message(
      'Login with Access Token',
      name: 'login_type_access_token',
      desc: '',
      args: [],
    );
  }

  /// `Login with Password`
  String get login_type_password {
    return Intl.message(
      'Login with Password',
      name: 'login_type_password',
      desc: '',
      args: [],
    );
  }

  /// `Access Token`
  String get login_hint_access_token {
    return Intl.message(
      'Access Token',
      name: 'login_hint_access_token',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get login_hint_password {
    return Intl.message(
      'Password',
      name: 'login_hint_password',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get login_hint_username {
    return Intl.message(
      'Username',
      name: 'login_hint_username',
      desc: '',
      args: [],
    );
  }

  /// `Server Address`
  String get login_hint_host {
    return Intl.message(
      'Server Address',
      name: 'login_hint_host',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Memos Host and Account Information`
  String get login_tips {
    return Intl.message(
      'Please enter your Memos Host and Account Information',
      name: 'login_tips',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get title_explore {
    return Intl.message('Explore', name: 'title_explore', desc: '', args: []);
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
