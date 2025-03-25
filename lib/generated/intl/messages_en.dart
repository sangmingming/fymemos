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

  static String m3(count) =>
      "${Intl.plural(count, zero: 'Tag', one: 'Tag', other: 'Tags')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "button_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "button_login": MessageLookupByLibrary.simpleMessage("Login"),
    "button_logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "button_save": MessageLookupByLibrary.simpleMessage("Save"),
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
    "hint_search": MessageLookupByLibrary.simpleMessage("Search Memos..."),
    "memo_days": m1,
    "memo_memos": m2,
    "memo_tags": m3,
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Light"),
    "theme_system": MessageLookupByLibrary.simpleMessage("System"),
    "title_about": MessageLookupByLibrary.simpleMessage("About"),
    "title_archived": MessageLookupByLibrary.simpleMessage("Archived"),
    "title_delete_tag": MessageLookupByLibrary.simpleMessage("Delete Tag"),
    "title_home": MessageLookupByLibrary.simpleMessage("Home"),
    "title_login": MessageLookupByLibrary.simpleMessage("Login"),
    "title_memo": MessageLookupByLibrary.simpleMessage("Memo"),
    "title_resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "title_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "title_theme": MessageLookupByLibrary.simpleMessage("Theme Mode"),
  };
}
