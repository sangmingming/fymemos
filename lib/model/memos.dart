class Memo {
  late final String name;
  late final String uid;
  late final String creator;
  late final String createTime;
  late final String displayTime;
  late final String content;

  Memo(this.name, this.uid, this.creator, this.createTime, this.displayTime, this.content);

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(json['name'] ?? "", 
      json['uid'] ?? "", 
      json['creator'] ?? "",
      json['createTime'] ?? "",
      json['displayTime'] ?? "",
      json['content'] ?? "");
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