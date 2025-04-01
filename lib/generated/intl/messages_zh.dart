// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(tag) => "确定要删除这个标签吗? 这同时会删除所有关联到 #${tag}的笔记。";

  static String m1(count) =>
      "${Intl.plural(count, zero: '天', one: '天', other: '天')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: '笔记', one: '笔记', other: '笔记')}";

  static String m3(snippet) => "被一条笔记引用: ${snippet}";

  static String m4(snippet) => "引用一条笔记: ${snippet}";

  static String m5(count) =>
      "${Intl.plural(count, zero: '没有与任何笔记关联', one: '与一条笔记关联', other: '与${count}条笔记关联')}";

  static String m6(count) =>
      "${Intl.plural(count, zero: '标签', one: '标签', other: '标签')}";

  static String m7(days) =>
      "${Intl.plural(days, zero: '刚刚', one: '昨天', other: '${days}天前')}";

  static String m8(hours) =>
      "${Intl.plural(hours, zero: '刚刚', one: '1小时前', other: '${hours}小时')}";

  static String m9(minutes) =>
      "${Intl.plural(minutes, zero: '刚刚', one: '1分钟前', other: '${minutes}分钟前')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "button_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "button_finish": MessageLookupByLibrary.simpleMessage("完成"),
    "button_login": MessageLookupByLibrary.simpleMessage("登录"),
    "button_logout": MessageLookupByLibrary.simpleMessage("登出"),
    "button_save": MessageLookupByLibrary.simpleMessage("保存"),
    "delete_memo_confirm": MessageLookupByLibrary.simpleMessage(
      "你确定要删除这篇笔记吗? ⚠️此操作不可撤销",
    ),
    "delete_tag_confirm": m0,
    "edit_Unpin": MessageLookupByLibrary.simpleMessage("取消置顶"),
    "edit_archive": MessageLookupByLibrary.simpleMessage("归档"),
    "edit_delete": MessageLookupByLibrary.simpleMessage("删除"),
    "edit_pin": MessageLookupByLibrary.simpleMessage("置顶"),
    "edit_rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "edit_restore": MessageLookupByLibrary.simpleMessage("恢复"),
    "hint_new_tag": MessageLookupByLibrary.simpleMessage("新标签名"),
    "hint_search": MessageLookupByLibrary.simpleMessage("搜索笔记..."),
    "login_hint_access_token": MessageLookupByLibrary.simpleMessage(
      "Access Token",
    ),
    "login_hint_host": MessageLookupByLibrary.simpleMessage("服务器地址"),
    "login_hint_password": MessageLookupByLibrary.simpleMessage("密码"),
    "login_hint_username": MessageLookupByLibrary.simpleMessage("用户名"),
    "login_tips": MessageLookupByLibrary.simpleMessage(
      "请输入你的Memos服务器地址和账户信息登录",
    ),
    "login_type_access_token": MessageLookupByLibrary.simpleMessage(
      "使用Access Token登录",
    ),
    "login_type_password": MessageLookupByLibrary.simpleMessage("使用用户名和密码登录"),
    "memo_days": m1,
    "memo_memos": m2,
    "memo_reference_by_one": m3,
    "memo_reference_one": m4,
    "memo_references": m5,
    "memo_tags": m6,
    "memo_title_detail": MessageLookupByLibrary.simpleMessage("笔记详情"),
    "msg_tag_delete": MessageLookupByLibrary.simpleMessage("标签已删除"),
    "msg_tag_rename": MessageLookupByLibrary.simpleMessage("标签改成成功"),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("隐私政策"),
    "share": MessageLookupByLibrary.simpleMessage("分析"),
    "theme_dark": MessageLookupByLibrary.simpleMessage("暗色"),
    "theme_light": MessageLookupByLibrary.simpleMessage("亮色"),
    "theme_system": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "time_days_ago": m7,
    "time_hours_ago": m8,
    "time_minutes_ago": m9,
    "time_now": MessageLookupByLibrary.simpleMessage("刚刚"),
    "title_about": MessageLookupByLibrary.simpleMessage("关于"),
    "title_archived": MessageLookupByLibrary.simpleMessage("归档"),
    "title_delete_tag": MessageLookupByLibrary.simpleMessage("删除标签"),
    "title_explore": MessageLookupByLibrary.simpleMessage("探索"),
    "title_home": MessageLookupByLibrary.simpleMessage("首页"),
    "title_login": MessageLookupByLibrary.simpleMessage("登录"),
    "title_memo": MessageLookupByLibrary.simpleMessage("笔记"),
    "title_rename_tag": MessageLookupByLibrary.simpleMessage("标签改名"),
    "title_resources": MessageLookupByLibrary.simpleMessage("资源"),
    "title_settings": MessageLookupByLibrary.simpleMessage("设置"),
    "title_theme": MessageLookupByLibrary.simpleMessage("主题"),
    "visibility_private": MessageLookupByLibrary.simpleMessage("仅自己可见"),
    "visibility_public": MessageLookupByLibrary.simpleMessage("公开"),
    "visibility_workspace": MessageLookupByLibrary.simpleMessage("工作空间可见"),
  };
}
