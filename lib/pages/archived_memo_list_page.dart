import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:fymemos/repo/repository.dart';

class ArchivedMemoListPage extends StatefulWidget {
  const ArchivedMemoListPage({super.key});

  @override
  State<ArchivedMemoListPage> createState() => _ArchivedMemoListPageState();
}

class _ArchivedMemoListPageState extends State<ArchivedMemoListPage> {
  List<Memo> memo = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  String? _nextPageToken;

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
    MemosResponse r = await fetchMemos(state: "ARCHIVED");
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
      state: "ARCHIVED",
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
    );
  }
}
