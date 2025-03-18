import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/pages/memolist/memo_list_vm.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  final String? memoState;

  _MemoListPageState({this.memoState});

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        _isLoadingMore = true;
        context.notifier(userMemoProvider).loadMore();
      }
    });
  }

  void _createMemo() async {
    final newMemo = await Navigator.of(
      context,
    ).push<Memo>(MaterialPageRoute(builder: (context) => CreateMemoPage()));
  }

  @override
  Widget build(BuildContext context) {
    final memo = context.watch(userMemoProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.notifier(userMemoProvider).init();
        },
        child: buildAsyncDataPage(memo, (item) {
          return _buildList(item);
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        tooltip: 'Create Memo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Memo> memos) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: memos.length + 1,
      itemBuilder: (context, index) {
        if (index == memos.length) {
          if (_isLoadingMore) {
            return Center(child: CircularProgressIndicator());
          }
          {
            return SizedBox.shrink(); // Empty space when not loading more and not at the end
          }
        } else {
          return MemoItem(memo: memos[index]);
        }
      },
    );
  }
}
