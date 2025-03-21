import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/memoedit/memo_edit_vm.dart';
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
    context.notifier(memoEditVMProvider).updateContent(content);
    final memo = await context.notifier(memoEditVMProvider).saveMemo();
    switch (memo) {
      case Ok<Memo>():
        {
          context.notifier(memoEditVMProvider).clear();
          Navigator.of(context).pop(memo.value);
        }
        break;
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

  void _takePhoto() async {
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

    if (!context.mounted) {
      return;
    }
    if (pickedFile != null) {
      context.notifier(memoEditVMProvider).addImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = context.watch(userSettingProvider);
    if (userSettings.data != null) {
      context
          .notifier(memoEditVMProvider)
          .updateVisibility(userSettings.data!.memoVisibility);
    }
    final images = context.watch(memoEditVMProvider).images;
    return Scaffold(
      appBar: AppBar(title: Text('Create Memo')),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _buildBottomAppbar(context),
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
            SizedBox(height: 8),
            _buildImageList(images),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList(List<MemoImage> images) {
    if (images.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Expanded(
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(width: 8),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child:
                        images[index].file != null
                            ? Image.file(
                              images[index].file!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                            : Image.network(
                              images[index].memoResource?.thumbnailUrl ?? "",
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              headers: ApiClient.instance.requestHeaders,
                            ),
                  ),

                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton.filled(
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(backgroundColor: Colors.grey),
                      onPressed: () {
                        context
                            .notifier(memoEditVMProvider)
                            .deleteImage(images[index]);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: images.length,
        ),
      );
    }
  }

  Widget _buildBottomAppbar(BuildContext context) {
    return Transform.translate(
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
              onPressed: _takePhoto,
              icon: Icon(Icons.photo_camera_outlined),
            ),
            IconButton(
              icon: Icon(Icons.image_outlined),
              onPressed: _pickFromGallery,
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
    );
  }

  Widget _buildMemoVisibilityButton() {
    final currentVisibility = context.watch(memoEditVMProvider).visibility;
    return PopupMenuButton(
      requestFocus: false,
      position: PopupMenuPosition.under,
      initialValue: context.watch(memoEditVMProvider).visibility,
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
      icon: SvgPicture.asset(currentVisibility.icon, width: 14, height: 14),
      onCanceled: () => isShowDialog = false,
      onSelected: (MemoVisibility value) {
        context.notifier(memoEditVMProvider).updateVisibility(value);
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

  // 添加相册权限检查
  Future<bool> checkStoragePermission() async {
    final status = await Permission.photos.status;
    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // 添加相册选择方法
  void _pickFromGallery() async {
    final hasPermission = await checkStoragePermission();
    if (!hasPermission) return null;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (!context.mounted) {
      return;
    }
    if (pickedFile != null) {
      context.notifier(memoEditVMProvider).addImage(File(pickedFile.path));
    }
  }
}
