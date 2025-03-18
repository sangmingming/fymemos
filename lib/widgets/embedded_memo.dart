import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/utils/load_state.dart';

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
    ApiClient.instance.getMemo(memoResourceName).then((memo) {
      if (memo is Success<Memo>) {
        setState(() {
          _memo = memo.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
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
