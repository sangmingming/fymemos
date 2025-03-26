import 'package:flutter/material.dart';
import 'package:fymemos/pages/common_page.dart';
import 'package:fymemos/pages/memodetail/memo_detail_vm.dart';
import 'package:fymemos/utils/l10n.dart';
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
            content: Text(context.intl.delete_memo_confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.intl.button_cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.intl.edit_delete),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await vm.deleteMemo();
      if (context.mounted) {
        Navigator.of(context).pop(); // 返回上级页面
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
            title: Text(context.intl.memo_title_detail),
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
