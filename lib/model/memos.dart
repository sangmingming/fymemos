import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Memo {
  late final String name;
  late final String uid;
  late final String creator;
  late final DateTime createTime;
  late final DateTime displayTime;
  late final String content;
  late final Visibility visibility;

  Memo(this.name, this.uid, this.creator, this.createTime, this.displayTime, this.content, this.visibility);

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(json['name'] ?? "", 
      json['uid'] ?? "", 
      json['creator'] ?? "",
      DateTime.parse(json['createTime'] ?? DateTime.now().toIso8601String()),
      DateTime.parse(json['displayTime'] ?? DateTime.now().toIso8601String()),
      json['content'] ?? "",
      Visibility.fromString(json['visibility'] ?? ""));
  }

  String getFormattedDisplayTime() {
    final now = DateTime.now();
    final difference = now.difference(displayTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat.yMMMd().format(displayTime);
    }
  }

}

enum Visibility {
  Public(icon: "assets/image/memo_public.svg", name: "PUBLIC"),
  Private(icon: "assets/image/memo_private.svg", name: "PRIVATE"),
  Protected(icon: "assets/image/memo_workspace.svg", name: "PROTECTED");



  const Visibility({required this.icon, required this.name, });

  final String icon;
  final String name;

  factory Visibility.fromString(String name) {
    switch (name) {
      case "PUBLIC":
        return Visibility.Public;
      case "PRIVATE":
        return Visibility.Private;
      case "PROTECTED":
        return Visibility.Protected;
      default:
        return Visibility.Public;
    }
  }
}

class MemosResponse {
  List<Memo>? memos;
  String? nextPageToken;

  MemosResponse({this.memos, this.nextPageToken});

  factory MemosResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = json['memos'] as List<dynamic>;
    List<Memo> memos = list.map((item) => 
      Memo.fromJson(item as Map<String, dynamic>)
    ).toList();
    return MemosResponse(
      memos: memos,
      nextPageToken: json['nextPageToken']  
    );
  }
}