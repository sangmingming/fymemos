import 'package:flutter/material.dart';
import 'package:fymemos/pages/memodetail/memo_detail_vm.dart';
import 'package:fymemos/utils/strings.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';

class EmbeddedMemoItem extends StatefulWidget {
  final String memoResourceName;

  const EmbeddedMemoItem({super.key, required this.memoResourceName});

  @override
  State<StatefulWidget> createState() => _EmbeddedMemoItemState();
}

class _EmbeddedMemoItemState extends State<EmbeddedMemoItem> {
  late String memoResourceName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.family(
      provider: memoDetailProvider(widget.memoResourceName.id),
      init: (context) {},
      builder: (context, vm) {
        return Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                vm.memo.when(
                  data:
                      (memo) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => {context.go('/${memo.name}')},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(memo.getFormattedDisplayTime(context)),
                                Spacer(),
                                Text(memo.name.id),
                                Icon(Icons.arrow_outward),
                              ],
                            ),
                            Text(memo.snippet, textAlign: TextAlign.start),
                          ],
                        ),
                      ),
                  loading: () => CircularProgressIndicator(),
                  error:
                      (obj, stack) => Text(
                        obj.toString(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
