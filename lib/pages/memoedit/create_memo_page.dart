import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/memoedit/memo_edit_vm.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:refena_flutter/refena_flutter.dart';

class CreateMemoPage extends StatefulWidget {
  final Map<String, String?> params;
  CreateMemoPage({this.params = const {}});
  @override
  _CreateMemoPageState createState() => _CreateMemoPageState();
}

class _CreateMemoPageState extends State<CreateMemoPage> with Refena {
  final TextEditingController _contentController = TextEditingController();
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

  void _initData() {
    widget.params.forEach((key, value) {
      switch (key) {
        case 'content':
          _contentController.text = value ?? '';
          break;
        case 'image':
          if (value == null) {
            return;
          }
          ref.notifier(memoEditVMProvider).addImage(File(value));
          break;
      }
    });
    widget.params.clear();
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
    ref.notifier(memoEditVMProvider).updateContent(content);
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
    _initData();
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 12,
              right: 12,
              bottom: 8,
            ),
            child: TextField(
              key: _textFieldKey,
              controller: _contentController,
              focusNode: _contentFocusNode,
              maxLines: 5,
              minLines: 5,
              keyboardType: TextInputType.multiline,
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
          _buildImageList(images),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildImageList(List<MemoImage> images) {
    if (images.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        width: double.infinity,
        margin: EdgeInsets.only(top: 8),
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(width: 8),
          shrinkWrap: true,
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

  Widget _buildBottomRow(BuildContext context) {
    final theme = BottomAppBarTheme.of(context);
    final color = ElevationOverlay.applySurfaceTint(
      theme.color ?? Colors.transparent,
      theme.surfaceTintColor,
      1.0,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(color: color),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildMemoVisibilityButton(),
          IconButton(
            onPressed: () {
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
                Icon(visibility.systemIcon),
                SizedBox(width: 5),
                Text(visibility.displayText),
              ],
            ),
          );
        }).toList();
      },
      icon: Icon(currentVisibility.systemIcon),
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
    final addStr =
        (cursorPos == 0 || text.substring(cursorPos - 1, cursorPos) != '#')
            ? '#$tag '
            : '$tag ';

    final newText = text.replaceRange(cursorPos, cursorPos, addStr);
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: cursorPos + addStr.length,
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

Future<Memo?> showCreateMemoPage(BuildContext context) async {
  return await showModalBottomSheet<Memo>(
    context: context,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
    ),
    isScrollControlled: true, // 允许内容滚动
    builder: (context) => CreateMemoPage(),
  );
}
