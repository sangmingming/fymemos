import 'package:dio/dio.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memo_request.dart';
import 'package:fymemos/model/memos.dart';
import 'package:refena_flutter/refena_flutter.dart';

class MemoDetailVm {
  final AsyncValue<Memo> memo;
  final Function deleteMemo;
  final Function restoreMemo;
  final Function archiveMemo;
  final Function pinMemo;
  final Function unpinMemo;
  MemoDetailVm({
    required this.memo,
    required this.deleteMemo,
    required this.restoreMemo,
    required this.archiveMemo,
    required this.pinMemo,
    required this.unpinMemo,
  });
}

class MemoDetailNotifier extends AsyncNotifier<Memo> {
  String? _memoId;
  @override
  Future<Memo> init() async {
    state = AsyncValue.loading();
    throw UnimplementedError();
  }

  Future<void> initialize(String memoId) async {
    _memoId = memoId;
    state = AsyncValue.loading();
    state = await _loadMemo(memoId);
  }

  Future<AsyncValue<Memo>> _loadMemo(String memoId) async {
    try {
      final apiClient = ApiClient.instance;
      return AsyncValue.data(await apiClient.getMemoDirect(memoId));
    } on DioException catch (e) {
      return AsyncValue.error(e, e.stackTrace);
    }
  }

  Future<void> refresh() async {
    if (_memoId != null) {
      state = await _loadMemo(_memoId!);
    }
  }

  Future<void> deleteMemo() async {
    state = AsyncValue.loading();
    if (_memoId != null) {
      await ApiClient.instance.deleteMemoDirect(_memoId!);
    }
  }
}

final memoDetailDataProvider = FutureProvider.family<Memo, String>(
  (ref, memoId) => ApiClient.instance.getMemoDirect(memoId),
);

final memoDetailProvider = ViewProvider.family<MemoDetailVm, String>((
  ref,
  memoId,
) {
  final data = ref.watch(memoDetailDataProvider(memoId));
  return MemoDetailVm(
    memo: data,
    deleteMemo: () async {
      await ApiClient.instance.deleteMemo(memoId);
    },
    restoreMemo: () async {
      if (data.hasData && data.data != null) {
        final request = UpdateMemoRequest.copyFromMemo(
          data.data!,
          state: MemoState.normal.value,
        );
        await ApiClient.instance.updateMemo(request.name, request);
        ref.rebuild(memoDetailDataProvider(memoId));
      }
    },
    archiveMemo: () async {
      if (data.hasData && data.data != null) {
        final request = UpdateMemoRequest.copyFromMemo(
          data.data!,
          state: MemoState.archived.value,
        );
        await ApiClient.instance.updateMemo(request.name, request);
        ref.rebuild(memoDetailDataProvider(memoId));
      }
    },
    pinMemo: () async {
      if (data.hasData && data.data != null) {
        final request = UpdateMemoRequest.copyFromMemo(
          data.data!,
          pinned: true,
        );
        await ApiClient.instance.updateMemo(request.name, request);
        ref.rebuild(memoDetailDataProvider(memoId));
      }
    },
    unpinMemo: () async {
      if (data.hasData && data.data != null) {
        final request = UpdateMemoRequest.copyFromMemo(
          data.data!,
          pinned: false,
        );
        await ApiClient.instance.updateMemo(request.name, request);
        ref.rebuild(memoDetailDataProvider(memoId));
      }
    },
  );
});
