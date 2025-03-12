import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Memo {
  late final String name;
  late final String uid;
  late final String creator;
  late final DateTime createTime;
  late final DateTime displayTime;
  late final String content;
  late final MemoVisibility visibility;

  Memo(
    this.name,
    this.uid,
    this.creator,
    this.createTime,
    this.displayTime,
    this.content,
    this.visibility,
  );

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      json['name'] ?? "",
      json['uid'] ?? "",
      json['creator'] ?? "",
      DateTime.parse(json['createTime'] ?? DateTime.now().toIso8601String()),
      DateTime.parse(json['displayTime'] ?? DateTime.now().toIso8601String()),
      json['content'] ?? "",
      MemoVisibility.fromString(json['visibility'] ?? ""),
    );
  }

  String getFormattedDisplayTime() {
    final now = DateTime.now();
    final difference = now.difference(displayTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
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

class CreateMemoRequest {
  late final String content;
  late final MemoVisibility visibility;

  CreateMemoRequest(this.content, this.visibility);

  Map<String, dynamic> toJson() {
    return {'content': content, 'visibility': visibility.name};
  }
}

enum MemoVisibility {
  Public(
    icon: "assets/image/memo_public.svg",
    name: "PUBLIC",
    displayText: "公开",
  ),
  Private(
    icon: "assets/image/memo_private.svg",
    name: "PRIVATE",
    displayText: "仅自己可见",
  ),
  Protected(
    icon: "assets/image/memo_workspace.svg",
    name: "PROTECTED",
    displayText: "工作空间可见",
  );

  const MemoVisibility({
    required this.icon,
    required this.name,
    required this.displayText,
  });

  final String icon;
  final String name;
  final String displayText;

  factory MemoVisibility.fromString(String name) {
    switch (name) {
      case "PUBLIC":
        return MemoVisibility.Public;
      case "PRIVATE":
        return MemoVisibility.Private;
      case "PROTECTED":
        return MemoVisibility.Protected;
      default:
        return MemoVisibility.Public;
    }
  }
}

class MemosResponse {
  List<Memo>? memos;
  String? nextPageToken;

  MemosResponse({this.memos, this.nextPageToken});

  factory MemosResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = json['memos'] as List<dynamic>;
    List<Memo> memos =
        list
            .map((item) => Memo.fromJson(item as Map<String, dynamic>))
            .toList();
    return MemosResponse(memos: memos, nextPageToken: json['nextPageToken']);
  }
}
