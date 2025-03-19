import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/pages/archivedlist/archived_memo_vm.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:fymemos/model/memos.dart';

class MemoListController extends AsyncNotifier<List<Memo>> {
  String? _nextPageToken;
  String? user;
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

  void loadMore() async {
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
}

final userMemoProvider = AsyncNotifierProvider<MemoListController, List<Memo>>(
  (ref) => MemoListController(),
);
