import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:fymemos/repo/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoListPage extends StatefulWidget {
  final String? memoState;
  const MemoListPage({super.key, this.memoState});

  @override
  State<MemoListPage> createState() => _MemoListPageState(memoState: memoState);
}

class _MemoListPageState extends State<MemoListPage> {
  List<Memo> memo = [];
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
      final sp = await SharedPreferences.getInstance();
      user = await sp.getString("user");
    }
    MemosResponse r = await fetchMemos(parent: user, state: memoState);
    if (r.memos != null) {
      setState(() {
        memo = r.memos!;
        _nextPageToken = r.nextPageToken;
      });
    }
  }

  Future<void> loadMoreData() async {
    if (_nextPageToken == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    MemosResponse r = await fetchMemos(
      pageToken: _nextPageToken!,
      state: memoState,
    );
    print(r.nextPageToken ?? "is null");
    if (r.memos != null) {
      setState(() {
        memo.addAll(r.memos!);
        if (r.nextPageToken != null && r.nextPageToken!.isNotEmpty) {
          _nextPageToken = r.nextPageToken;
        } else {
          _nextPageToken = null;
        }
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _nextPageToken = null;
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
        memo.insert(0, newMemo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: memo.length + 1,
          itemBuilder: (context, index) {
            if (index == memo.length) {
              if (_isLoadingMore) {
                return Center(child: CircularProgressIndicator());
              } else if (_nextPageToken == null) {
                return Center(child: Text('No more data'));
              } else {
                return SizedBox.shrink(); // Empty space when not loading more and not at the end
              }
            } else {
              return MemoItem(memo: memo[index]);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        tooltip: 'Create Memo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
