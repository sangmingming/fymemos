import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/common_page.dart';
import 'package:fymemos/pages/memodetail/memo_detail_vm.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MemoDetailPage extends StatelessWidget {
  final String resourceName;

  const MemoDetailPage({super.key, required this.resourceName});

  void _deleteMemo(BuildContext context, MemoDetailVm vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Text('Are you sure delete this memo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await vm.deleteMemo();
      if (context.mounted) {
        Navigator.of(context)..pop(); // 返回上级页面
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.family(
      provider: memoDetailProvider(resourceName),
      init: (context) {},
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Memo Detail"),
            actions: [
              if (vm.memo.hasData && vm.memo.data != null)
                PopupMenuButton(
                  itemBuilder: createMemoOptionMenu(
                    context: context,
                    memo: vm.memo.data!,
                    onDeleteClick: () async {
                      _deleteMemo(context, vm);
                    },
                    onArchiveClick: () async {
                      await vm.archiveMemo();
                    },
                    onRestoreClick: () async {
                      await vm.restoreMemo();
                    },
                    onPinClick: () async {
                      await vm.pinMemo();
                    },
                    onUnpinClick: () async {
                      await vm.unpinMemo();
                    },
                    onShareClick: () async {
                      await Share.share(vm.memo.data!.content);
                    },
                  ),
                  offset: Offset(0, 42),
                  icon: Icon(Icons.more_horiz_rounded),
                ),
            ],
          ),
          body: Column(
            children: [
              vm.memo.when(
                data: (data) => MemoItem(memo: data, isDetail: true),
                loading: () => LoadingPage(),
                error: (e, s) => ErrorPage(error: e.toString()),
              ),
            ],
          ),
        );
      },
    );
  }
}
