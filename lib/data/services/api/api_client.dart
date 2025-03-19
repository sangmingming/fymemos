import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fymemos/model/memo_request.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/utils/result.dart';

class ApiClient {
  int PAGE_SIZE = 20;

  static final instance = ApiClient();

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
    //dio.transformer =
    dio.transformer = BackgroundTransformer();
    //..jsonDecodeCallback = parseJson;
  }

  Future<LoadState<MemosResponse>> fetchMemos({
    String? parent,
    String? pageToken,
    String? state,
    String? filter,
  }) async {
    try {
      final res = await dio.get(
        "/api/v1/memos",
        queryParameters: {
          if (parent != null) 'parent': parent,
          if (pageToken != null) 'pageToken': pageToken,
          if (state != null) 'state': state,
          if (filter != null) 'filter': filter,
          'pageSize': PAGE_SIZE,
        },
      );
      return LoadState.ok(
        MemosResponse.fromJson(res.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return LoadState.error(e);
    }
  }

  Future<LoadState<MemosResponse>> fetchUserMemos({
    required user,
    String? pageToken,
    String? state,
    String? filter,
  }) async {
    try {
      final res = await dio.get(
        "/api/v1/$user/memos",
        queryParameters: {
          if (pageToken != null) 'pageToken': pageToken,
          if (state != null) 'state': state,
          if (filter != null) 'filter': filter,
          'pageSize': PAGE_SIZE,
        },
      );
      return LoadState.ok(
        MemosResponse.fromJson(res.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return LoadState.error(e);
    }
  }

  Future<MemosResponse> fetchUserMemosDirect({
    required user,
    String? pageToken,
    String? state,
    String? filter,
  }) async {
    final res = await dio.get(
      "/api/v1/$user/memos",
      queryParameters: {
        if (pageToken != null) 'pageToken': pageToken,
        if (state != null) 'state': state,
        if (filter != null) 'filter': filter,
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

  Future<Result<Memo>> createMemo(CreateMemoRequest request) async {
    try {
      final res = await dio.post(
        "/api/v1/memos",
        data: jsonEncode(request.toJson()), // Ensure the data is JSON encoded
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Set the content type to JSON
          },
        ),
      );
      return Result.ok(Memo.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Result.error(e);
    }
  }

  Future<LoadState<Memo>> getMemo(String name) async {
    try {
      final res = await dio.get("/api/v1/$name");
      return LoadState.success(Memo.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return LoadState.error(e);
    }
  }

  Future<Memo> getMemoDirect(String name) async {
    final res = await dio.get("/api/v1/memos/${getId(name)}");
    return Memo.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Result<UserStats>> getUserStats(String name) async {
    try {
      final res = await dio.get("/api/v1/$name/stats");
      return Result.ok(UserStats.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<UserProfile>> getAuthStatus() async {
    try {
      final res = await dio.post("/api/v1/auth/status");
      return Result.ok(UserProfile.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Result.error(e);
    }
  }

  Future<UserStats> getUserStatsDirect(String name) async {
    final res = await dio.get("/api/v1/$name/stats");
    return UserStats.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserProfile> getAuthStatusDirect() async {
    final res = await dio.post("/api/v1/auth/status");
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Map<String, dynamic> _parseAndDecode(String response) {
    return jsonDecode(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  Future<Result<void>> deleteMemo(String name) async {
    try {
      await dio.delete("/api/v1/memos/${getId(name)}");
      return Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e);
    }
  }

  Future<void> deleteMemoDirect(String name) async {
    await dio.delete("/api/v1/memos/${getId(name)}");
  }

  Future<Result<Memo>> updateMemo(
    String name,
    UpdateMemoRequest request,
  ) async {
    try {
      final res = await dio.patch(
        "/api/v1/$name",
        data: jsonEncode(request.toJson()), // Ensure the data is JSON encoded
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Set the content type to JSON
          },
        ),
      );
      return Result.ok(Memo.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Result.error(e);
    }
  }

  String getId(String name) {
    return name.contains("/") ? name.split("/").last : name;
  }
}
