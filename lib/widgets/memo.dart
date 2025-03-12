import 'package:flutter/widgets.dart';

import '../model/memos.dart';

class MemoItem extends StatelessWidget {
  MemoItem({required this.memo, super.key});
  Memo memo;
  @override
  Widget build(BuildContext context) {
    return Text(memo.content, style: TextStyle(fontFamily: "Noto"),);
  }


}