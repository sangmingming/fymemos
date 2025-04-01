import 'dart:convert';
import 'dart:io';

import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memo_request.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/utils/result.dart';
import 'package:fymemos/utils/strings.dart';
import 'package:mime/mime.dart';
import 'package:refena_flutter/refena_flutter.dart';

final memoEditVMProvider = NotifierProvider<MemoEditVM, MemoEditData>(
  (ref) => MemoEditVM(),
);

class MemoEditVM extends Notifier<MemoEditData> {
  @override
  MemoEditData init() {
    return MemoEditData(
      content: "",
      images: [],
      visibility: MemoVisibility.Public,
    );
  }

  void updateVisibility(MemoVisibility visibility) {
    state = state.copyWith(newVisibility: visibility, initial: true);
  }

  void clear() {
    state = init();
  }

  Future<MemoResource> _uploadImage(File image) async {
    final fileName = image.path.split("/").last;
    final type = "image/${fileName.split(".").last}";
    final bytes = await image.readAsBytes();
    final base64Content = base64Encode(bytes);
    return await ApiClient.instance.createResource(
      CreateResourceRequest(
        filename: fileName,
        content: base64Content,
        type: type,
      ),
    );
  }

  bool _isImageFile(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType?.startsWith('image/') ?? false;
  }

  void addImage(File image) async {
    print("image: ${image.path}");
    final images = state.images ?? [];
    if (!_isImageFile(image)) {
      return;
    }
    images.add(MemoImage(file: image));
    state = state.copyWith(image: images);
    final res = await _uploadImage(image);
    images.firstWhere((element) => element.file == image).memoResource = res;
  }

  void deleteImage(MemoImage img) async {
    final images = state.images ?? [];
    images.remove(img);
    state = state.copyWith(image: images);
    if (img.memoResource != null) {
      await ApiClient.instance.deleteResource(img.memoResource!.name.id);
    }
  }

  void updateContent(String content) {
    state = state.copyWith(desc: content);
  }

  Future<Result<Memo>> saveMemo() async {
    final images = await checkImages();
    final imageData =
        images
            .skipWhile((element) => element.memoResource == null)
            .map((e) => e.memoResource!)
            .toList();
    final request = CreateMemoRequest(
      state.content,
      state.visibility,
      imageData,
    );
    return await ApiClient.instance.createMemo(request);
  }

  Future<List<MemoImage>> checkImages() async {
    final images = state.images ?? [];
    for (final img in images) {
      if (img.file == null) {
        continue;
      }
      if (img.memoResource != null) {
        continue;
      }
      img.memoResource = await _uploadImage(img.file!);
    }
    return images;
  }
}

class MemoEditData {
  final String content;
  final String? memoName;
  final List<MemoImage> images;
  final MemoVisibility visibility;
  final bool initial;

  MemoEditData copyWith({
    List<MemoImage>? image,
    String? name,
    String? desc,
    MemoVisibility? newVisibility,
    bool? initial,
  }) {
    return MemoEditData(
      content: desc ?? content,
      images: image ?? images,
      memoName: name ?? memoName,
      visibility: newVisibility ?? visibility,
      initial: initial ?? this.initial,
    );
  }

  MemoEditData({
    required this.content,
    required this.images,
    required this.visibility,
    this.memoName,
    this.initial = false,
  });
}

class MemoImage {
  File? file;
  MemoResource? memoResource;

  MemoImage({this.file, this.memoResource});
}
