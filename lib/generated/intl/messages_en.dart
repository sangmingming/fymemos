// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(tag) =>
      "Are you sure you want to delete this tag? This will remove all memos related to #${tag}.";

  static String m1(count) =>
      "${Intl.plural(count, zero: 'Day', one: 'Day', other: 'Days')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Memo', one: 'Memo', other: 'Memos')}";

  static String m3(snippet) => "Referenced by 1 memo: ${snippet}";

  static String m4(snippet) => "Referencing 1 memo: ${snippet}";

  static String m5(count) =>
      "${Intl.plural(count, zero: 'Referencing with 0 memo', one: 'Referencing with 1 memo', other: 'Referencing with ${count} memos')}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'Tag', one: 'Tag', other: 'Tags')}";

  static String m7(days) =>
      "${Intl.plural(days, zero: 'Now', one: 'Yesterday', other: '${days} days ago')}";

  static String m8(hours) =>
      "${Intl.plural(hours, zero: 'Now', one: '1 hour ago', other: '${hours} hours ago')}";

  static String m9(minutes) =>
      "${Intl.plural(minutes, zero: 'Now', one: '1 minute ago', other: '${minutes} minutes ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "button_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "button_finish": MessageLookupByLibrary.simpleMessage("Finish"),
    "button_login": MessageLookupByLibrary.simpleMessage("Login"),
    "button_logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "button_save": MessageLookupByLibrary.simpleMessage("Save"),
    "content_hint": MessageLookupByLibrary.simpleMessage("Any thoughts..."),
    "delete_memo_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this memo? THIS ACTION IS IRREVERSIBLE",
    ),
    "delete_tag_confirm": m0,
    "edit_Unpin": MessageLookupByLibrary.simpleMessage("Unpin"),
    "edit_archive": MessageLookupByLibrary.simpleMessage("Archive"),
    "edit_delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "edit_pin": MessageLookupByLibrary.simpleMessage("Pin"),
    "edit_rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "edit_restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "empty_tips": MessageLookupByLibrary.simpleMessage(
      "Nothing here, start writing now!",
    ),
    "hint_new_tag": MessageLookupByLibrary.simpleMessage("New tag name"),
    "hint_search": MessageLookupByLibrary.simpleMessage("Search Memos..."),
    "login_hint_access_token": MessageLookupByLibrary.simpleMessage(
      "Access Token",
    ),
    "login_hint_host": MessageLookupByLibrary.simpleMessage("Server Address"),
    "login_hint_password": MessageLookupByLibrary.simpleMessage("Password"),
    "login_hint_username": MessageLookupByLibrary.simpleMessage("Username"),
    "login_tips": MessageLookupByLibrary.simpleMessage(
      "Please enter your Memos Host and Account Information",
    ),
    "login_type_access_token": MessageLookupByLibrary.simpleMessage(
      "Login with Access Token",
    ),
    "login_type_password": MessageLookupByLibrary.simpleMessage(
      "Login with Password",
    ),
    "memo_days": m1,
    "memo_memos": m2,
    "memo_reference_by_one": m3,
    "memo_reference_one": m4,
    "memo_references": m5,
    "memo_tags": m6,
    "memo_title_detail": MessageLookupByLibrary.simpleMessage("Memo Detail"),
    "msg_tag_delete": MessageLookupByLibrary.simpleMessage("Tag deleted"),
    "msg_tag_rename": MessageLookupByLibrary.simpleMessage("Tag renamed"),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Light"),
    "theme_system": MessageLookupByLibrary.simpleMessage("System"),
    "time_days_ago": m7,
    "time_hours_ago": m8,
    "time_minutes_ago": m9,
    "time_now": MessageLookupByLibrary.simpleMessage("Now"),
    "title_about": MessageLookupByLibrary.simpleMessage("About"),
    "title_archived": MessageLookupByLibrary.simpleMessage("Archived"),
    "title_delete_tag": MessageLookupByLibrary.simpleMessage("Delete Tag"),
    "title_explore": MessageLookupByLibrary.simpleMessage("Explore"),
    "title_home": MessageLookupByLibrary.simpleMessage("Home"),
    "title_login": MessageLookupByLibrary.simpleMessage("Login"),
    "title_memo": MessageLookupByLibrary.simpleMessage("Memo"),
    "title_rename_tag": MessageLookupByLibrary.simpleMessage("Rename Tag"),
    "title_resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "title_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "title_theme": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "visibility_private": MessageLookupByLibrary.simpleMessage("Private"),
    "visibility_public": MessageLookupByLibrary.simpleMessage("Public"),
    "visibility_workspace": MessageLookupByLibrary.simpleMessage("Workspace"),
  };
}
