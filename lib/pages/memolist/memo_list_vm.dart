import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memo_request.dart';
import 'package:fymemos/pages/archivedlist/archived_memo_vm.dart';
import 'package:fymemos/utils/result.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:fymemos/model/memos.dart';

class MemoListVm {
  final bool isSearchMode;
  final List<Memo> memos;
  final String? lastPageToken;
  final bool isLoading;
  final String? searchKey;
  MemoListVm({
    required this.isSearchMode,
    required this.memos,
    required this.lastPageToken,
    required this.isLoading,
    this.searchKey,
  });

  MemoListVm copyWith({
    bool? isSearchMode,
    List<Memo>? memos,
    String? lastPageToken,
    bool? isLoading,
    String? searchKey,
  }) {
    return MemoListVm(
      isSearchMode: isSearchMode ?? this.isSearchMode,
      memos: memos ?? this.memos,
      lastPageToken: lastPageToken ?? this.lastPageToken,
      isLoading: isLoading ?? this.isLoading,
      searchKey: searchKey ?? this.searchKey,
    );
  }

  factory MemoListVm.init() {
    return MemoListVm(
      isSearchMode: false,
      memos: [],
      lastPageToken: null,
      isLoading: true,
      searchKey: null,
    );
  }
}

class _MemoListInitAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  @override
  Future<MemoListVm> reduce() async {
    final userResult =
        await SharedPreferencesService.instance.fetchUserDirect();
    final user = userResult;
    final result = await ApiClient.instance.fetchUserMemosDirect(user: user);
    String? nextToken = null;
    if (result.memos == null || result.memos!.isEmpty) {
      nextToken = '';
    } else {
      nextToken = result.nextPageToken;
    }
    return MemoListVm(
      isSearchMode: false,
      memos: result.memos ?? [],
      lastPageToken: nextToken,
      isLoading: false,
      searchKey: null,
    );
  }
}

class RefreshMemoAction extends ReduxAction<MemoListController, MemoListVm> {
  @override
  MemoListVm reduce() {
    if (state.isLoading) {
      return state;
    }
    return state.copyWith(
      isLoading: true,
      isSearchMode: false,
      searchKey: null,
    );
  }

  @override
  void after() {
    super.after();
    dispatchAsync(_MemoListInitAction());
  }
}

class LoadMoreMemoAction extends ReduxAction<MemoListController, MemoListVm> {
  @override
  MemoListVm reduce() {
    if (state.isLoading) {
      return state;
    }

    if (state.lastPageToken == null || state.lastPageToken == '') {
      return state.copyWith(lastPageToken: '');
    }
    dispatch(_SetLoadingAction());
    dispatchAsync(_LoadMoreMemoAction());
    return state;
  }
}

class _SetLoadingAction extends ReduxAction<MemoListController, MemoListVm> {
  @override
  MemoListVm reduce() {
    return state.copyWith(isLoading: true);
  }
}

class _LoadMoreMemoAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  @override
  Future<MemoListVm> reduce() async {
    if (state.lastPageToken == null || state.lastPageToken == '') {
      return state;
    }
    final userResult =
        await SharedPreferencesService.instance.fetchUserDirect();
    final user = userResult;
    final searchKey =
        state.isSearchMode && state.searchKey != null
            ? 'content.contains("${state.searchKey}")'
            : null;
    final result = await ApiClient.instance.fetchUserMemosDirect(
      user: user,
      pageToken: state.lastPageToken,
      filter: searchKey,
    );
    String? nextToken;
    if (result.memos == null || result.memos!.isEmpty) {
      nextToken = '';
    } else {
      nextToken = result.nextPageToken;
    }
    final list = state.memos;
    list.addAll(result.memos ?? []);
    return state.copyWith(
      isLoading: false,
      memos: list,
      lastPageToken: nextToken,
    );
  }
}

class SearchMemoAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  final String query;
  SearchMemoAction(this.query);
  @override
  Future<MemoListVm> reduce() async {
    if (state.isLoading) {
      return state;
    }
    final userResult =
        await SharedPreferencesService.instance.fetchUserDirect();
    final user = userResult;
    final searchKey =
        state.isSearchMode && state.searchKey != null
            ? 'content.contains("${state.searchKey}")'
            : null;
    final result = await ApiClient.instance.fetchUserMemosDirect(
      user: user,
      pageToken: null,
      filter: searchKey,
    );
    String? nextToken;
    if (result.memos == null || result.memos!.isEmpty) {
      nextToken = '';
    } else {
      nextToken = result.nextPageToken;
    }
    return state.copyWith(
      isLoading: false,
      memos: result.memos ?? [],
      lastPageToken: nextToken,
      isSearchMode: true,
      searchKey: query,
    );
  }
}

class DeleteMemoAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  final BuildContext context;
  DeleteMemoAction(this.memo, this.context);
  @override
  Future<MemoListVm> reduce() async {
    await ApiClient.instance.deleteMemoDirect(memo.name);
    bool result = state.memos.contains(memo);
    if (!result) {
      context.ref.notifier(archivedMemoProvider).refresh();
    }
    return state.copyWith(
      memos: state.memos.where((element) => element.name != memo.name).toList(),
    );
  }
}

class ArchiveMemoAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  final BuildContext context;
  ArchiveMemoAction(this.memo, this.context);
  @override
  Future<MemoListVm> reduce() async {
    final request = UpdateMemoRequest.copyFromMemo(memo, state: "ARCHIVED");
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      context.ref.notifier(archivedMemoProvider).refresh();
      final list = state.memos;
      list.removeWhere((element) => element.name == memo.name);
      return state.copyWith(memos: list);
    }
    return state;
  }
}

class RestoreMemoAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  final BuildContext context;
  RestoreMemoAction(this.memo, this.context);
  @override
  Future<MemoListVm> reduce() async {
    final request = UpdateMemoRequest.copyFromMemo(memo, state: "NORMAL");
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      context.ref.notifier(archivedMemoProvider).refresh();
      final list = state.memos;
      list.insert(0, res.value);
      return state.copyWith(memos: list);
    }
    return state;
  }
}

class PinMemoAction extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  PinMemoAction(this.memo);
  @override
  Future<MemoListVm> reduce() async {
    final request = UpdateMemoRequest.copyFromMemo(memo, pinned: true);
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      final list = state.memos;
      final index = list.indexWhere((element) => element.name == request.name);
      list[index] = res.value;
      return state.copyWith(memos: list);
    }
    return state;
  }
}

class AddMemoAction extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  AddMemoAction(this.memo);
  @override
  Future<MemoListVm> reduce() async {
    final list = state.memos;
    list.insert(0, memo);
    return state.copyWith(memos: list);
  }
}

class UnpinMemoAction extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  UnpinMemoAction(this.memo);
  @override
  Future<MemoListVm> reduce() async {
    final request = UpdateMemoRequest.copyFromMemo(memo, pinned: false);
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      final list = state.memos;
      final index = list.indexWhere((element) => element.name == request.name);
      list[index] = res.value;
      return state.copyWith(memos: list);
    }
    return state;
  }
}

class UpdateMemoAction
    extends AsyncReduxAction<MemoListController, MemoListVm> {
  final Memo memo;
  UpdateMemoAction(this.memo);
  @override
  Future<MemoListVm> reduce() async {
    final request = UpdateMemoRequest.copyFromMemo(memo);
    final res = await ApiClient.instance.updateMemo(memo.name, request);
    if (res is Ok<Memo>) {
      final list = state.memos;
      final index = list.indexWhere((element) => element.name == request.name);
      list[index] = res.value;
      return state.copyWith(memos: list);
    }
    return state;
  }
}

class MemoListController extends ReduxNotifier<MemoListVm> {
  @override
  BaseReduxAction<ReduxNotifier<MemoListVm>, MemoListVm, dynamic>?
  get initialAction => _MemoListInitAction();

  @override
  MemoListVm init() {
    return MemoListVm.init();
  }
}

final userMemoProvider = ReduxProvider<MemoListController, MemoListVm>(
  (ref) => MemoListController(),
);
