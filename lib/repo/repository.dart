import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fymemos/model/memos.dart';

final dio = Dio();
final token = "eyJhbGciOiJIUzI1NiIsImtpZCI6InYxIiwidHlwIjoiSldUIn0.eyJuYW1lIjoibGlubWluZzEwMDdAZ21haWwuY29tIiwiaXNzIjoibWVtb3MiLCJzdWIiOiIxIiwiYXVkIjpbInVzZXIuYWNjZXNzLXRva2VuIl0sImV4cCI6NDg5NDMxMjMwNiwiaWF0IjoxNzQwNzEyMzA2fQ.r0hg_ZmMLxqfy0nlYKxjxq5M9urU1MVe3es2ike5Xdw";

void initDio() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers["Authorization"] = "Bearer $token";
        return handler.next(options);
      },
    )
  );
  dio.transformer = DefaultTransformer()..jsonDecodeCallback = parseJson;
}
Future<MemosResponse> fetchMemos({String? pageToken}) async {
  final res = await dio.get("https://memos.isming.info/api/v1/memos", 
  queryParameters: {
      if (pageToken != null) 'pageToken': pageToken,
    },);
  return MemosResponse.fromJson(res.data as Map<String, dynamic>);
}

Map<String, dynamic> _parseAndDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> parseJson(String text) {
  return compute(_parseAndDecode, text);
}

