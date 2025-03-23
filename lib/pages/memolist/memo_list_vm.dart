import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memo_request.dart';
import 'package:fymemos/pages/archivedlist/archived_memo_vm.dart';
import 'package:fymemos/utils/result.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:fymemos/model/memos.dart';

class MemoListController extends AsyncNotifier<List<Memo>> {
  String? _nextPageToken;
  String? user;
  bool isLoading = false;
  bool isSearchMode = false;

  @override
  Future<List<Memo>> init() async {
    final userResult =
        await SharedPreferencesService.instance.fetchUserDirect();
    user = userResult;
    final result = await ApiClient.instance.fetchUserMemosDirect(user: user);
    if (result.memos == null || result.memos!.isEmpty) {
      _nextPageToken = null;
    } else {
      _nextPageToken = result.nextPageToken;
    }
    return result.memos?.toList() ?? [];
  }

  void search(String query) async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    if (user == null) {
      final userResult =
          await SharedPreferencesService.instance.fetchUserDirect();
      user = userResult;
    }

    final result = await ApiClient.instance.fetchUserMemosDirect(
      user: user,
      filter: 'content.contains("$query")',
    );
    if (result.memos == null || result.memos!.isEmpty) {
      _nextPageToken = null;
    } else {
      _nextPageToken = result.nextPageToken;
    }
    isLoading = false;
    state = AsyncValue.data(result.memos?.toList() ?? []);
  }

  Future<void> refresh() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    final userResult =
        await SharedPreferencesService.instance.fetchUserDirect();
    user = userResult;
    final result = await ApiClient.instance.fetchUserMemosDirect(user: user);
    if (result.memos == null || result.memos!.isEmpty) {
      _nextPageToken = null;
    } else {
      _nextPageToken = result.nextPageToken;
    }
    isLoading = false;
    state = AsyncValue.data(result.memos?.toList() ?? []);
  }

  Future<void> loadMore() async {
    if (_nextPageToken == null) {
      return;
    }
    final result = await ApiClient.instance.fetchUserMemosDirect(
      user: user,
      pageToken: _nextPageToken,
    );
    if (result.memos == null || result.memos!.isEmpty) {
      _nextPageToken = null;
    } else {
      _nextPageToken = result.nextPageToken;
      state.data?.addAll(result.memos!);
    }
  }

  Future<void> deleteMemo(Memo memo) async {
    await ApiClient.instance.deleteMemoDirect(memo.name);
    bool result = state.data?.contains(memo) ?? false;
    if (!result) {
      await ref.notifier(archivedMemoProvider).init();
    }
    setState((snapshot) async {
      return snapshot.curr?.where((element) => element != memo).toList() ?? [];
    });
  }

  Future<void> archiveMemo(Memo memo) async {
    final request = UpdateMemoRequest.copyFromMemo(memo, state: "ARCHIVED");
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      setState((snapshot) async {
        final list = snapshot.curr ?? [];
        list.removeWhere((element) => element.name == memo.name);
        return list;
      });
      ref.notifier(archivedMemoProvider).refresh();
    }
  }

  Future<void> restoreMemo(Memo memo) async {
    final request = UpdateMemoRequest.copyFromMemo(memo, state: "NORMAL");
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      setState((snapshot) async {
        final list = snapshot.curr ?? [];
        list.insert(0, res.value);
        return list;
      });
    }
    ref.notifier(archivedMemoProvider).refresh();
  }

  Future<void> pinMemo(Memo memo) async {
    final request = UpdateMemoRequest.copyFromMemo(memo, pinned: true);
    debugPrint("pin memo $request");
    await updateMemoWitRequest(request);
  }

  Future<void> unpinMemo(Memo memo) async {
    final request = UpdateMemoRequest.copyFromMemo(memo, pinned: false);
    await updateMemoWitRequest(request);
  }

  Future<void> updateMemoWitRequest(UpdateMemoRequest request) async {
    final res = await ApiClient.instance.updateMemo(request.name, request);
    if (res is Ok<Memo>) {
      setState((snapshot) async {
        final list = snapshot.curr ?? [];
        final index = list.indexWhere(
          (element) => element.name == request.name,
        );
        list[index] = res.value;
        return list;
      });
    }
  }

  Future<void> updateMemo(Memo memo) async {
    final content = memo.nodes.join('');
    final request = UpdateMemoRequest.copyFromMemo(memo, content: content);
    final res = await ApiClient.instance.updateMemo(request.name, request);
    if (res is Ok<Memo>) {
      setState((snapshot) async {
        final list = snapshot.curr ?? [];
        final index = list.indexWhere((element) => element.name == memo.name);
        list[index] = res.value;
        return list;
      });
    }
  }

  Future<void> addMemo(Memo memo) async {
    setState((snapshot) async {
      final list = snapshot.curr ?? [];
      list.insert(0, memo);
      return list;
    });
  }
}

final userMemoProvider = AsyncNotifierProvider<MemoListController, List<Memo>>(
  (ref) => MemoListController(),
);
