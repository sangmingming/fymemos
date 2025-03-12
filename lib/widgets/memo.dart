import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../model/memos.dart';

class MemoItem extends StatelessWidget {
  const MemoItem({required this.memo, super.key});
  final Memo memo;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(memo.visibility.icon, width: 14, height: 14),
                SizedBox(width: 5),
                Text(memo.getFormattedDisplayTime(), style: Theme.of(context).textTheme.labelMedium,),
              ],
            ),
            SizedBox(height: 5),
            Text(memo.content, style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),
      ),
      );
  }


}