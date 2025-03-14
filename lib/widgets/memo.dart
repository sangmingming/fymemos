import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fymemos/model/node_render.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/repo/repository.dart';
import 'package:fymemos/widgets/related_memo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/memos.dart';

class MemoResourceCard extends StatelessWidget {
  const MemoResourceCard({
    required this.resources,
    required this.onResourceTap,
    super.key,
  });
  final List<MemoResource> resources;
  final Function(MemoResource) onResourceTap;
  @override
  Widget build(BuildContext context) {
    int crossAxisCount;
    if (resources.length < 4) {
      crossAxisCount = resources.length;
    } else if (resources.length == 4) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return MemoImageItem(resource: resources[index], fit: BoxFit.cover);
      },
    );
  }
}

class MemoImageItem extends StatelessWidget {
  const MemoImageItem({required this.resource, this.fit, super.key});
  final MemoResource resource;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showImageDialog(context, resource),
      child: Hero(
        tag: resource.name,
        child: CachedNetworkImage(
          imageUrl: resource.thumbnailUrl,
          fit: fit,
          httpHeaders: requestHeaders,
        ),
      ),
    );
  }
}

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
                Text(
                  memo.getFormattedDisplayTime(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            SizedBox(height: 5),
            ...memo.nodes.map((node) {
              return NodeRenderer(node: node);
            }),
            SizedBox(height: 5),
            ...memo.relations.map((relatedMemo) {
                  return RelatedMemoItem(memo: relatedMemo.relatedMemo);
                }) ??
                [],
            if (memo.resources.isNotEmpty)
              MemoResourceCard(
                resources: memo.resources,
                onResourceTap: (resource) {
                  showImageDialog(context, resource);
                },
              ),
          ],
        ),
      ),
    );
  }
}

void showImageDialog(BuildContext context, MemoResource resource) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.9), // 设置更深的背景颜色
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: InteractiveViewer(
              child: Hero(
                tag: resource.name,
                child: CachedNetworkImage(
                  imageUrl: resource.imageUrl,
                  httpHeaders: requestHeaders,
                  placeholder:
                      (context, url) => CachedNetworkImage(
                        imageUrl: resource.thumbnailUrl,
                        fit: BoxFit.fitHeight,
                        httpHeaders: requestHeaders,
                      ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
