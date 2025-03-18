import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/utils/result.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ArchivedMemoNotifier extends AsyncNotifier<List<Memo>> {
  String? _nextPageToken;
  String? user;
  @override
  Future<List<Memo>> init() async {
    final userResult = await SharedPreferencesService.instance.fetchUser();
    if (userResult is Ok) {
      user = (userResult as Ok).value;
      final result = await ApiClient.instance.fetchUserMemosDirect(
        user: user,
        state: MemoState.archived.value,
      );
      if (result.memos == null || result.memos!.isEmpty) {
        _nextPageToken = null;
      } else {
        _nextPageToken = result.nextPageToken;
      }
      return result.memos?.toList() ?? [];
    }

    return [];
  }

  void loadMore() async {
    if (_nextPageToken == null) {
      return;
    }
    final result = await ApiClient.instance.fetchUserMemosDirect(
      user: user,
      state: MemoState.archived.value,
      pageToken: _nextPageToken,
    );
    if (result.memos == null || result.memos!.isEmpty) {
      _nextPageToken = null;
    } else {
      _nextPageToken = result.nextPageToken;
      state.data?.addAll(result.memos!);
    }
  }
}

final archivedMemoProvider =
    AsyncNotifierProvider<ArchivedMemoNotifier, List<Memo>>(
      (ref) => ArchivedMemoNotifier(),
    );
