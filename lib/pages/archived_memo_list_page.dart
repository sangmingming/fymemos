import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/widgets/memo.dart';

class ArchivedMemoListPage extends StatefulWidget {
  const ArchivedMemoListPage({super.key});

  @override
  State<ArchivedMemoListPage> createState() => _ArchivedMemoListPageState();
}

class _ArchivedMemoListPageState extends State<ArchivedMemoListPage> {
  LoadState<List<Memo>> memo = LoadState.loading();
  List<Memo> _memoData = [];
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
    final r = await ApiClient.instance.fetchMemos(state: "ARCHIVED");
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

  Future<void> loadMoreData() async {
    if (_nextPageToken == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    final r = await ApiClient.instance.fetchMemos(
      pageToken: _nextPageToken!,
      state: "ARCHIVED",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildResult(memo),
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
