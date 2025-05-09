import 'package:fymemos/model/memos.dart';
import 'package:fymemos/model/resources.dart';

class CreateResourceRequest {
  final String filename;
  final String content;
  final String type;
  final String? memo;

  CreateResourceRequest({
    required this.filename,
    required this.content,
    required this.type,
    this.memo,
  });

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'content': content,
      'type': type,
      if (memo != null) 'memo': memo,
    };
  }
}

class UpdateMemoRequest {
  final String name;
  String? content;
  String? state;
  MemoVisibility? visibility;
  List<MemoResource>? resources;
  bool? pinned;

  UpdateMemoRequest({
    required this.name,
    this.content,
    this.state,
    this.visibility,
    this.pinned,
    this.resources,
  });

  factory UpdateMemoRequest.copyFromMemo(
    Memo memo, {
    String? content,
    String? state,
    bool? pinned,
    List<MemoResource>? resources,
    MemoVisibility? visibility,
  }) {
    return UpdateMemoRequest(
      name: memo.name,
      content: content ?? memo.content,
      state: state ?? memo.state.value,
      visibility: visibility ?? memo.visibility,
      pinned: pinned ?? memo.pinned,
      resources: resources ?? memo.resources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (content != null) 'content': content,
      if (state != null) 'state': state,
      if (visibility != null) 'visibility': visibility!.name,
      if (pinned != null) 'pinned': pinned,
    };
  }

  @override
  String toString() {
    return toJson().entries.join("");
  }
}
