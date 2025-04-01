import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/utils/strings.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:fymemos/model/memos.dart';

class ExploreMemoVm {
  final List<Memo> memos;
  final String? lastPageToken;
  final bool isLoading;
  final Map<String, UserProfile> userCaches;
  ExploreMemoVm({
    required this.memos,
    required this.lastPageToken,
    required this.isLoading,
    required this.userCaches,
  });

  ExploreMemoVm copyWith({
    List<Memo>? memos,
    String? lastPageToken,
    bool? isLoading,
    Map<String, UserProfile>? userCaches,
  }) {
    return ExploreMemoVm(
      memos: memos ?? this.memos,
      lastPageToken: lastPageToken ?? this.lastPageToken,
      isLoading: isLoading ?? this.isLoading,
      userCaches: userCaches ?? this.userCaches,
    );
  }

  factory ExploreMemoVm.init() {
    return ExploreMemoVm(
      memos: [],
      lastPageToken: null,
      isLoading: true,
      userCaches: {},
    );
  }
}

class _MemoListInitAction
    extends AsyncReduxAction<ExploreMemoListController, ExploreMemoVm> {
  @override
  Future<ExploreMemoVm> reduce() async {
    Map<String, UserProfile> userCaches = state.userCaches;

    final result = await ApiClient.instance.fetchMemos();
    String? nextToken = null;
    if (result.memos == null || result.memos!.isEmpty) {
      nextToken = '';
    } else {
      nextToken = result.nextPageToken;
    }
    result.memos?.forEach((element) async {
      String uid = element.creator.id;
      if (userCaches.containsKey(uid)) {
        final user = userCaches[uid];
        element.creatorName = user?.name ?? '';
        element.creatorAvatar = user?.avatarUrl ?? '';
      } else {
        final user = await ApiClient.instance.getUser(uid);
        element.creatorName = user.nickname;
        element.creatorAvatar = user.avatarUrl ?? "";
        userCaches[uid] = user;
      }
    });
    return ExploreMemoVm(
      memos: result.memos ?? [],
      lastPageToken: nextToken,
      isLoading: false,
      userCaches: userCaches,
    );
  }
}

class RefreshMemoAction
    extends ReduxAction<ExploreMemoListController, ExploreMemoVm> {
  @override
  ExploreMemoVm reduce() {
    if (state.isLoading) {
      return state;
    }
    return state.copyWith(isLoading: true);
  }

  @override
  void after() {
    super.after();
    dispatchAsync(_MemoListInitAction());
  }
}

class LoadMoreMemoAction
    extends ReduxAction<ExploreMemoListController, ExploreMemoVm> {
  @override
  ExploreMemoVm reduce() {
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

class _SetLoadingAction
    extends ReduxAction<ExploreMemoListController, ExploreMemoVm> {
  @override
  ExploreMemoVm reduce() {
    return state.copyWith(isLoading: true);
  }
}

class _LoadMoreMemoAction
    extends AsyncReduxAction<ExploreMemoListController, ExploreMemoVm> {
  @override
  Future<ExploreMemoVm> reduce() async {
    if (state.lastPageToken == null || state.lastPageToken == '') {
      return state;
    }

    final result = await ApiClient.instance.fetchMemos(
      pageToken: state.lastPageToken,
    );
    Map<String, UserProfile> userCaches = state.userCaches;
    result.memos?.forEach((element) async {
      String uid = element.creator.id;
      if (userCaches.containsKey(uid)) {
        final user = userCaches[uid];
        if (user?.nickname.isEmpty ?? true) {
          element.creatorName = user?.username ?? '';
        } else {
          element.creatorName = user?.nickname ?? user?.username ?? '';
        }
        element.creatorAvatar = user?.avatarUrl ?? '';
      } else {
        final user = await ApiClient.instance.getUser(uid);
        element.creatorName =
            user.nickname.isEmpty ? user.username : user.nickname;
        element.creatorAvatar = user.avatarUrl ?? "";
        userCaches[uid] = user;
      }
    });
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
      userCaches: userCaches,
    );
  }
}

class ExploreMemoListController extends ReduxNotifier<ExploreMemoVm> {
  @override
  BaseReduxAction<ReduxNotifier<ExploreMemoVm>, ExploreMemoVm, dynamic>?
  get initialAction => _MemoListInitAction();

  @override
  ExploreMemoVm init() {
    return ExploreMemoVm.init();
  }
}

final exploreMemoProvider =
    ReduxProvider<ExploreMemoListController, ExploreMemoVm>(
      (ref) => ExploreMemoListController(),
    );
