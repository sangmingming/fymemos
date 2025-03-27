import 'package:fymemos/model/memos.dart';
import 'package:fymemos/utils/datetime.dart';

class UserStats {
  final String name;
  final Map<String, int> tagCount;
  final List<DateTime> memoTimes;

  UserStats({
    required this.name,
    required this.tagCount,
    required this.memoTimes,
  });

  Map<DateTime, int> get memoHeatData {
    final Map<DateTime, int> data = {};
    memoTimes.forEach((time) {
      final key = time.midnight;
      data[key] = (data[key] ?? 0) + 1;
    });
    return data;
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final List<DateTime> memoTimes =
        (json['memoDisplayTimestamps'] as List)
            .map((e) => DateTime.parse(e as String))
            .toList();
    return UserStats(
      name: json['name'] as String,
      tagCount: json['tagCount'].cast<String, int>(),
      memoTimes: memoTimes,
    );
  }
}

class UserProfile {
  final String name;
  final String username;
  final String nickname;
  final String role;
  final String email;
  final String? description;
  final String? avatarUrl;
  final String? state;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? token;

  const UserProfile({
    required this.name,
    required this.username,
    required this.nickname,
    required this.role,
    required this.email,
    this.description,
    this.avatarUrl,
    this.state,
    this.createTime,
    this.updateTime,
    this.token,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? nickname,
    String? role,
    String? email,
    String? description,
    String? avatarUrl,
    String? state,
    DateTime? createTime,
    DateTime? updateTime,
    String? token,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      email: email ?? this.email,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      state: state ?? this.state,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      token: token ?? this.token,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      state: json['state'] as String?,
      createTime:
          json['createTime'] == null
              ? null
              : DateTime.parse(json['createTime'] as String),
      updateTime:
          json['updateTime'] == null
              ? null
              : DateTime.parse(json['updateTime'] as String),
    );
  }
}

class UserSttings {
  final MemoVisibility memoVisibility;

  UserSttings({required this.memoVisibility});

  factory UserSttings.fromJson(Map<String, dynamic> json) {
    return UserSttings(
      memoVisibility: MemoVisibility.fromString(json['memoVisibility']),
    );
  }
}
