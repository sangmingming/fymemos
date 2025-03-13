class MemoResource {
  final String name;
  final DateTime createTime;
  final String filename;
  final String type;
  final String size;
  final String memo;

  String get imageUrl {
    return "https://memos.isming.info/file/$name/$filename";
  }

  String get thumbnailUrl {
    return "https://memos.isming.info/file/$name/$filename?thumbnail=true";
  }

  MemoResource({
    required this.name,
    required this.createTime,
    required this.filename,
    required this.type,
    required this.size,
    required this.memo,
  });

  factory MemoResource.fromJson(Map<String, dynamic> json) {
    return MemoResource(
      name: json['name'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      filename: json['filename'] as String,
      type: json['type'] as String,
      size: json['size'] as String,
      memo: json['memo'] as String,
    );
  }
}

class MemoResourcesResponse {
  final List<MemoResource>? resources;

  MemoResourcesResponse({this.resources});

  factory MemoResourcesResponse.fromJson(Map<String, dynamic> json) {
    final List<MemoResource> resources =
        (json['resources'] as List)
            .map((e) => MemoResource.fromJson(e as Map<String, dynamic>))
            .toList();
    return MemoResourcesResponse(resources: resources);
  }
}
