import 'package:flutter/material.dart';
import 'package:fymemos/model/memo_nodes.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/utils/l10n.dart';
import 'package:intl/intl.dart';

class Memo {
  late final String name;
  late final String uid;
  late final String creator;
  late final DateTime createTime;
  late final DateTime displayTime;
  late final String content;
  late final MemoVisibility visibility;
  final bool pinned;
  final List<MemoResource> resources;
  final List<Node> nodes;
  final String snippet;
  final List<Relation> relations;
  final MemoState state;

  Memo(
    this.name,
    this.uid,
    this.creator,
    this.createTime,
    this.displayTime,
    this.content,
    this.visibility,
    this.pinned,
    this.resources,
    this.nodes,
    this.snippet,
    this.relations,
    this.state,
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
      json['pinned'] ?? false,
      (json['resources'] as List<dynamic>)
          .map((item) => MemoResource.fromJson(item as Map<String, dynamic>))
          .toList(),
      (json['nodes'] as List<dynamic>)
          .map((item) => Node.fromJson(item as Map<String, dynamic>))
          .toList(),
      json['snippet'] ?? "",
      (json['relations'] as List<dynamic>? ?? [])
          .map((item) => Relation.fromJson(item as Map<String, dynamic>))
          .toList(),
      MemoState.fromString(json['state']),
    );
  }

  String getFormattedDisplayTime(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(displayTime);

    if (difference.inSeconds < 60) {
      return context.intl.time_now;
    } else if (difference.inMinutes < 60) {
      return context.intl.time_minutes_ago(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return context.intl.time_hours_ago(difference.inHours);
    } else if (difference.inDays < 7) {
      return context.intl.time_days_ago(difference.inDays);
    } else {
      return DateFormat.yMMMd()
          .addPattern(DateFormat.HOUR24_MINUTE)
          .format(displayTime);
    }
  }
}

class Relation {
  final RelatedMemo relatedMemo;
  final RelatedMemo memo;

  Relation(this.memo, this.relatedMemo);

  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      RelatedMemo.fromJson(json['memo']),
      RelatedMemo.fromJson(json['relatedMemo']),
    );
  }
}

class RelatedMemo {
  final String name;
  final String uid;
  final String snippet;

  RelatedMemo(this.name, this.uid, this.snippet);

  factory RelatedMemo.fromJson(Map<String, dynamic> json) {
    return RelatedMemo(
      json['name'] ?? "",
      json['uid'] ?? "",
      json['snippet'] ?? "",
    );
  }
}

class CreateMemoRequest {
  late final String content;
  late final MemoVisibility visibility;
  final List<MemoResource> resource;

  CreateMemoRequest(this.content, this.visibility, this.resource);

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'visibility': visibility.name,
      if (resource.isNotEmpty)
        'resources': resource.map((e) => e.toJson()).toList(),
    };
  }
}

enum MemoState {
  normal("NORMAL"),
  archived("ARCHIVED");

  final String value;

  const MemoState(this.value);

  factory MemoState.fromString(String? value) {
    switch (value) {
      case "NORMAL":
        return MemoState.normal;
      case "ARCHIVED":
        return MemoState.archived;
      default:
        return MemoState.normal;
    }
  }
}

enum MemoVisibility {
  Public(
    icon: "assets/image/memo_public.svg",
    name: "PUBLIC",
    displayText: "visibility_public",
    systemIcon: Icons.public_outlined,
  ),
  Private(
    icon: "assets/image/memo_private.svg",
    name: "PRIVATE",
    displayText: "visibility_private",
    systemIcon: Icons.lock_outline,
  ),
  Protected(
    icon: "assets/image/memo_workspace.svg",
    name: "PROTECTED",
    displayText: "visibility_workspace",
    systemIcon: Icons.group_outlined,
  );

  const MemoVisibility({
    required this.icon,
    required this.name,
    required this.displayText,
    required this.systemIcon,
  });

  final String icon;
  final String name;
  final String displayText;
  final IconData systemIcon;

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
