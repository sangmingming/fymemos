import 'package:flutter/material.dart';
import 'package:fymemos/pages/explore/explore_vm.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ExplorePage extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  ExplorePage({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch(exploreMemoProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.redux(exploreMemoProvider).dispatch(RefreshMemoAction());
        },
        child: _buildList(context, vm),
      ),
    );
  }

  Widget _buildList(BuildContext context, ExploreMemoVm vm) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !vm.isLoading) {
        context.redux(exploreMemoProvider).dispatch(LoadMoreMemoAction());
      }
    });
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
