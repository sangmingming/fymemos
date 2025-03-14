import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fymemos/model/memos.dart';

class RelatedMemoItem extends StatelessWidget {
  final RelatedMemo memo;

  const RelatedMemoItem({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => {Navigator.pushNamed(context, '/${memo.name}')},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Spacer(),
                      Text(memo.name),
                      Icon(Icons.arrow_outward),
                    ],
                  ),
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
