import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/archivedlist/archived_memo_vm.dart';
import 'package:fymemos/pages/common_page.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ArchivedMemoListPage extends StatefulWidget {
  const ArchivedMemoListPage({super.key});

  @override
  State<ArchivedMemoListPage> createState() => _ArchivedMemoListPageState();
}

class _ArchivedMemoListPageState extends State<ArchivedMemoListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        _isLoadingMore = true;
        context.notifier(archivedMemoProvider).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final memo = context.watch(archivedMemoProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.notifier(archivedMemoProvider).init();
        },
        child: buildAsyncDataPage(memo, (item) {
          return _buildList(item);
        }),
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
          } else if (memos.isEmpty) {
            return EmptyPage();
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
