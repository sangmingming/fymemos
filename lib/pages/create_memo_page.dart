import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/utils/result.dart';

class CreateMemoPage extends StatefulWidget {
  @override
  _CreateMemoPageState createState() => _CreateMemoPageState();
}

class _CreateMemoPageState extends State<CreateMemoPage> {
  final TextEditingController _contentController = TextEditingController();
  MemoVisibility _visibility = MemoVisibility.Public;

  void _saveMemo() async {
    final content = _contentController.text;
    if (content.isEmpty) {
      // Show an error message if content is empty
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Content cannot be empty')));
      return;
    }

    final request = CreateMemoRequest(content, _visibility);
    final memo = await ApiClient.instance.createMemo(request);
    switch (memo) {
      case Ok<Memo>():
        Navigator.of(context).pop(memo);
      case Error():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('create memo failed: ${memo.error.toString()}'),
          ),
        );
    }
    // Close the page after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('创作')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isCollapsed: false,
                  labelText: 'Content',
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<MemoVisibility>(
              value: _visibility,
              onChanged: (MemoVisibility? newValue) {
                setState(() {
                  _visibility = newValue!;
                });
              },
              items:
                  MemoVisibility.values.map((MemoVisibility visibility) {
                    return DropdownMenuItem<MemoVisibility>(
                      value: visibility,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            visibility.icon,
                            width: 14,
                            height: 14,
                          ),
                          SizedBox(width: 5),
                          Text(visibility.displayText),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _saveMemo, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
