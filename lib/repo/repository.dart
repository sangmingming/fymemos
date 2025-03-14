import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/model/users.dart';

const int PAGE_SIZE = 20;

final dio = Dio();
final Map<String, String> requestHeaders = {};

void initDio({required baseUrl, required token}) {
  dio.options.baseUrl = baseUrl;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers["Authorization"] = "Bearer $token";
        return handler.next(options);
      },
    ),
  );
  requestHeaders["Authorization"] = "Bearer $token";
  dio.interceptors.add(
    LogInterceptor(
      responseBody: true,
      requestHeader: false,
      logPrint: (o) => debugPrint(o.toString()),
    ),
  );
  dio.transformer = DefaultTransformer()..jsonDecodeCallback = parseJson;
}

Future<MemosResponse> fetchMemos({
  String? parent,
  String? pageToken,
  String? state,
}) async {
  final res = await dio.get(
    "/api/v1/memos",
    queryParameters: {
      if (parent != null) 'parent': parent,
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

Future<Memo?> getMemo(String name) async {
  final res = await dio.get("/api/v1/$name");
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
