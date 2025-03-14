import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/repo/repository.dart';
import 'package:fymemos/widgets/memo.dart';

class MemoDetailPage extends StatefulWidget {
  final String resourceName;

  const MemoDetailPage({super.key, required this.resourceName});

  @override
  _MemoDetailPageState createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends State<MemoDetailPage> {
  late String resourceName;
  Memo? memo;

  @override
  void initState() {
    super.initState();
    resourceName = widget.resourceName;
    getMemo("memos/$resourceName").then((m) {
      setState(() {
        memo = m;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (memo != null) {
      widget = MemoItem(memo: memo!);
    } else {
      widget = CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(title: Text("Memo Detail")),
      body: Column(children: [widget]),
    );
  }
}
