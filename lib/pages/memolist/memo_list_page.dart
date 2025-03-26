import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/memolist/memo_list_vm.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';

class MemoListPage extends StatefulWidget {
  final String? memoState;
  const MemoListPage({super.key, this.memoState});

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> with Refena {
  final ScrollController _scrollController = ScrollController();

  String? memoState;

  _MemoListPageState();

  @override
  void initState() {
    super.initState();
    memoState = widget.memoState;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.redux(userMemoProvider).dispatch(LoadMoreMemoAction());
      }
    });
  }

  void _createMemo() async {
    final newMemo = await context.push<Memo>("/create_memo");
    if (newMemo != null) {
      context.redux(userMemoProvider).dispatchAsync(AddMemoAction(newMemo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch(userMemoProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.redux(userMemoProvider).dispatch(RefreshMemoAction());
        },
        child: _buildList(vm),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        tooltip: 'Create Memo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(MemoListVm vm) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: vm.memos.length + 1,
      itemBuilder: (context, index) {
        if (index == vm.memos.length) {
          if (vm.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SizedBox.shrink(); // Empty space when not loading more and not at the end
          }
        } else {
          return MemoItem(memo: vm.memos[index]);
        }
      },
    );
  }
}
