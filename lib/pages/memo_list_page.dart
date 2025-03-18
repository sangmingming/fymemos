import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/utils/result.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:refena_flutter/refena_flutter.dart';

class MemoListPage extends StatefulWidget {
  final String? memoState;
  const MemoListPage({super.key, this.memoState});

  @override
  State<MemoListPage> createState() => _MemoListPageState(memoState: memoState);
}

class _MemoListPageState extends State<MemoListPage> with Refena {
  List<Memo> _memoData = [];
  LoadState<List<Memo>> memo = LoadState.loading();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  String? _nextPageToken;
  String? user = null;

  final String? memoState;

  _MemoListPageState({this.memoState});

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        loadMoreData();
      }
    });
  }

  Future<void> loadData() async {
    if (user == null) {
      final userResult = await SharedPreferencesService.instance.fetchUser();
      if (userResult is Ok) {
        user = (userResult as Ok).value;
      }
    }
    LoadState<MemosResponse> r = await ApiClient.instance.fetchUserMemos(
      user: user,
      state: memoState,
    );
    switch (r) {
      case Loading():
        setState(() {
          memo = LoadState.loading();
        });
      case ErrorState():
        setState(() {
          memo = LoadState.error(r.error);
        });
      case Success():
        setState(() {
          _memoData = r.value.memos!;
          memo = LoadState.success(_memoData);
          _nextPageToken = r.value.nextPageToken;
        });
    }
  }

  Future<void> loadMoreData() async {
    if (_nextPageToken == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    LoadState<MemosResponse> r = await ApiClient.instance.fetchUserMemos(
      user: user,
      pageToken: _nextPageToken,
      state: memoState,
    );
    switch (r) {
      case Loading():
        setState(() {
          memo = LoadState.loading();
        });
      case ErrorState():
        setState(() {
          memo = LoadState.error(r.error);
        });
      case Success():
        setState(() {
          if (r.value.memos == null || r.value.memos!.isEmpty) {
            _nextPageToken = null;
          } else {
            _memoData.addAll(r.value.memos!);
            memo = LoadState.success(_memoData);
            _nextPageToken = r.value.nextPageToken;
          }
        });
    }
  }

  Future<void> _refreshData() async {
    await loadData();
  }

  void _createMemo() async {
    final newMemo = await Navigator.of(
      context,
    ).push<Memo>(MaterialPageRoute(builder: (context) => CreateMemoPage()));

    if (newMemo != null) {
      setState(() {
        _memoData.insert(0, newMemo);
        memo = LoadState.success(_memoData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildResult(memo),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        tooltip: 'Create Memo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResult(LoadState<List<Memo>> result) {
    return buildPage(result, (item) {
      return _buildList(item);
    });
  }

  Widget _buildList(List<Memo> memos) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: memos.length + 1,
      itemBuilder: (context, index) {
        if (index == memos.length) {
          if (_isLoadingMore) {
            return Center(child: CircularProgressIndicator());
          } else if (_nextPageToken == null) {
            return Center(child: Text('No more data'));
          } else {
            return SizedBox.shrink(); // Empty space when not loading more and not at the end
          }
        } else {
          return MemoItem(memo: memos[index]);
        }
      },
    );
  }
}
