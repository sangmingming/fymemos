import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/repo/repository.dart';

class EmbeddedMemoItem extends StatefulWidget {
  final String memoResourceName;

  const EmbeddedMemoItem({super.key, required this.memoResourceName});

  @override
  State<StatefulWidget> createState() => _EmbeddedMemoItemState();
}

class _EmbeddedMemoItemState extends State<EmbeddedMemoItem> {
  late String memoResourceName;
  Memo? _memo;

  @override
  void initState() {
    super.initState();
    memoResourceName = widget.memoResourceName;
    getMemo(memoResourceName).then((memo) {
      setState(() {
        _memo = memo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_memo != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {Navigator.pushNamed(context, '/${_memo!.name}')},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_memo!.getFormattedDisplayTime()),
                        Spacer(),
                        Text(_memo!.name),
                        Icon(Icons.arrow_outward),
                      ],
                    ),
                    Text(_memo!.snippet, textAlign: TextAlign.start),
                  ],
                ),
              )
            else
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
