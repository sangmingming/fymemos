import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/model/users.dart';

const int PAGE_SIZE = 20;

final dio = Dio();
final token =
    "eyJhbGciOiJIUzI1NiIsImtpZCI6InYxIiwidHlwIjoiSldUIn0.eyJuYW1lIjoibGlubWluZzEwMDdAZ21haWwuY29tIiwiaXNzIjoibWVtb3MiLCJzdWIiOiIxIiwiYXVkIjpbInVzZXIuYWNjZXNzLXRva2VuIl0sImV4cCI6NDg5NDMxMjMwNiwiaWF0IjoxNzQwNzEyMzA2fQ.r0hg_ZmMLxqfy0nlYKxjxq5M9urU1MVe3es2ike5Xdw";

void initDio() {
  dio.options.baseUrl = "https://memos.isming.info";
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers["Authorization"] = "Bearer $token";
        return handler.next(options);
      },
    ),
  );
  dio.transformer = DefaultTransformer()..jsonDecodeCallback = parseJson;
}

Future<MemosResponse> fetchMemos({String? pageToken, String? state}) async {
  final res = await dio.get(
    "/api/v1/memos",
    queryParameters: {
      if (pageToken != null) 'pageToken': pageToken,
      if (state != null) 'state': state,
      'pageSize': PAGE_SIZE,
    },
  );
  return MemosResponse.fromJson(res.data as Map<String, dynamic>);
}

Future<List<MemoResource>> fetchMemoResources() async {
  final res = await dio.get("/api/v1/resources");
  return MemoResourcesResponse.fromJson(
        res.data as Map<String, dynamic>,
      ).resources ??
      [];
}

Future<Memo?> createMemo(CreateMemoRequest request) async {
  final res = await dio.post(
    "/api/v1/memos",
    data: jsonEncode(request.toJson()), // Ensure the data is JSON encoded
    options: Options(
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
    ),
  );
  return Memo.fromJson(res.data as Map<String, dynamic>);
}

Future<UserStats> getUserStats(String name) async {
  final res = await dio.get("/api/v1/$name/stats");
  return UserStats.fromJson(res.data as Map<String, dynamic>);
}

Future<UserProfile> getAuthStatus() async {
  final res = await dio.post("/api/v1/auth/status");
  return UserProfile.fromJson(res.data as Map<String, dynamic>);
}

Map<String, dynamic> _parseAndDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> parseJson(String text) {
  return compute(_parseAndDecode, text);
}
