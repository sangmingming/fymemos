import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:refena_flutter/refena_flutter.dart';

class CreateMemoPage extends StatefulWidget {
  @override
  _CreateMemoPageState createState() => _CreateMemoPageState();
}

class _CreateMemoPageState extends State<CreateMemoPage> {
  final TextEditingController _contentController = TextEditingController();
  MemoVisibility? _visibility;
  final FocusNode _contentFocusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();

  bool isShowDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_contentFocusNode);
    });
  }

  void _saveMemo() async {
    final content = _contentController.text;
    if (content.isEmpty) {
      // Show an error message if content is empty
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Content cannot be empty')));
      return;
    }

    final request = CreateMemoRequest(
      content,
      _visibility ?? MemoVisibility.Public,
    );
    final memo = await ApiClient.instance.createMemo(request);
    switch (memo) {
      case Ok<Memo>():
        Navigator.of(context).pop(memo.value);
      case Error():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('create memo failed: ${memo.error.toString()}'),
          ),
        );
    }
    // Close the page after saving
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<File?> _takePhoto() async {
    final hasPermission = await checkCameraPermission();
    if (!hasPermission) {
      return null;
    }
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // 图片质量（0-100）
      maxWidth: 1200, // 最大宽度
      maxHeight: 1200, // 最大高度
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
      // 处理获取到的图片文件
      //_uploadImage(imageFile);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = context.watch(userSettingProvider);
    if (_visibility == null && userSettings.data != null) {
      setState(() {
        _visibility = userSettings.data?.memoVisibility;
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text('Create Memo')),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, -MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
          child: Row(
            children: [
              _buildMemoVisibilityButton(),
              IconButton(
                onPressed: () {
                  _contentController.text += '#';
                  _showTagDialog(context);
                },
                icon: Icon(Icons.tag_outlined),
              ),
              IconButton(
                onPressed: () {
                  final file = _takePhoto();
                  if (file != null) {
                    file.then((value) {
                      if (value != null) {
                        _contentController.text =
                            _contentController.text + '\n![](${value.path})';
                      }
                    });
                  }
                },
                icon: Icon(Icons.photo_camera_outlined),
              ),
              Spacer(),
              FilledButton.icon(
                onPressed: _saveMemo,
                label: Text('Save'),
                icon: Icon(Icons.send_outlined),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: _textFieldKey,
                controller: _contentController,
                focusNode: _contentFocusNode,
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
                onChanged: (text) {
                  if (isShowDialog) {
                    Navigator.of(context).pop();
                    isShowDialog = false;
                  }
                  final cursorPos = _contentController.selection.baseOffset;
                  if (cursorPos > 0) {
                    final lastChar = text.substring(cursorPos - 1, cursorPos);

                    if (lastChar == '#') {
                      if (cursorPos > 1) {
                        final prevChar = text.substring(
                          cursorPos - 2,
                          cursorPos - 1,
                        );
                        if (prevChar == '#') {
                          return;
                        }
                      }
                      _showTagDialog(context);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoVisibilityButton() {
    return PopupMenuButton(
      requestFocus: false,
      position: PopupMenuPosition.under,
      offset: Offset(0, -MediaQuery.of(context).viewInsets.bottom + 120),
      itemBuilder: (context) {
        return MemoVisibility.values.map((MemoVisibility visibility) {
          return PopupMenuItem<MemoVisibility>(
            value: visibility,
            child: Row(
              children: [
                SvgPicture.asset(visibility.icon, width: 24, height: 24),
                SizedBox(width: 5),
                Text(visibility.displayText),
              ],
            ),
          );
        }).toList();
      },
      icon: SvgPicture.asset(
        _visibility?.icon ?? 'assets/icons/public.svg',
        width: 14,
        height: 14,
      ),
      onCanceled: () => isShowDialog = false,
      onSelected: (MemoVisibility value) {
        setState(() {
          _visibility = value;
        });
      },
      onOpened: () => isShowDialog = true,
    );
  }

  void _showTagDialog(BuildContext context) async {
    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final boxSize = renderBox?.size ?? Size.zero;

    final tags =
        context.watch(authProvider).data?.stats.tagCount.keys.toList() ?? [];
    if (tags.isEmpty) {
      return;
    }

    isShowDialog = true;
    final selectTag = await showMenu(
      context: context,
      requestFocus: false,
      items:
          tags
              .map(
                (tag) => PopupMenuItem<String>(
                  value: tag,
                  child: ListTile(
                    leading: Icon(Icons.tag_outlined),
                    title: Text(tag),
                  ),
                ),
              )
              .toList(),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          offset.dx,
          offset.dy +
              boxSize.height -
              MediaQuery.of(context).viewInsets.bottom +
              -180,
          100,
          300,
        ),
        Offset.zero & MediaQuery.of(context).size,
      ),
    );
    isShowDialog = false;
    if (selectTag != null) {
      _insertTag(selectTag);
    }
  }

  // 插入标签方法
  void _insertTag(String tag) {
    final text = _contentController.text;
    final cursorPos = _contentController.selection.baseOffset;
    final newText = text.replaceRange(cursorPos, cursorPos, '$tag ');
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: cursorPos + tag.length + 1,
    );
  }
}
