import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:go_router/go_router.dart';

class RelatedMemoItem extends StatelessWidget {
  final RelatedMemo memo;
  final bool isReference;

  const RelatedMemoItem({
    super.key,
    required this.memo,
    required this.isReference,
  });

  @override
  Widget build(BuildContext context) {
    var icon = isReference ? Icons.arrow_outward : Icons.south_west;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => {context.go('/${memo.name}')},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Spacer(), Text(memo.name), Icon(icon)]),
                  Text(memo.snippet, textAlign: TextAlign.start),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
