import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memo_request.dart';
import 'package:fymemos/model/node_render.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/utils/result.dart';
import 'package:fymemos/widgets/related_memo.dart';
import 'package:share_plus/share_plus.dart';
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
          httpHeaders: ApiClient.instance.requestHeaders,
        ),
      ),
    );
  }
}

class MemoItem extends StatelessWidget {
  const MemoItem({required this.memo, this.isDetail = false, super.key});
  final Memo memo;
  final bool isDetail;
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
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
                Spacer(),
                if (!isDetail)
                  PopupMenuButton(
                    itemBuilder: createMemoBuilder(context, memo, () async {
                      final result = await ApiClient.instance.deleteMemo(
                        memo.name,
                      );
                      if (result is Ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Delete Success')),
                        );
                      }
                    }),
                    icon: Icon(Icons.more_horiz_rounded),
                  ),
              ],
            ),
            SizedBox(height: 5),
            ...memo.nodes.map((node) {
              return NodeRenderer(node: node);
            }),
            SizedBox(height: 5),

            if (memo.resources.isNotEmpty)
              MemoResourceCard(
                resources: memo.resources,
                onResourceTap: (resource) {
                  showImageDialog(context, resource);
                },
              ),

            if (memo.relations.isNotEmpty && !isDetail)
              RelatedMemoSimpleWidget(memo: memo),
            if (memo.relations.isNotEmpty && isDetail)
              Column(
                children:
                    memo.relations.map((relation) {
                      return RelatedMemoItem(
                        memo:
                            memo.name == relation.memo.name
                                ? relation.relatedMemo
                                : relation.memo,
                        isReference: memo.name == relation.memo.name,
                      );
                    }).toList(),
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
                  httpHeaders: ApiClient.instance.requestHeaders,
                  placeholder:
                      (context, url) => CachedNetworkImage(
                        imageUrl: resource.thumbnailUrl,
                        fit: BoxFit.fitHeight,
                        httpHeaders: ApiClient.instance.requestHeaders,
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

class RelatedMemoSimpleWidget extends StatelessWidget {
  const RelatedMemoSimpleWidget({required this.memo, super.key});
  final Memo memo;
  @override
  Widget build(BuildContext context) {
    if (memo.relations.isEmpty) {
      return SizedBox.shrink();
    } else if (memo.relations.length == 1) {
      var arrowIcon = Icons.north_west_rounded;
      var text =
          "Referencing 1 memo: ${memo.relations.first.relatedMemo.snippet}";
      if (memo.relations.first.memo.name != memo.name) {
        arrowIcon = Icons.south_east_rounded;
        text = "Referenced by 1 memo: ${memo.relations.first.memo.snippet}";
      }
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/${memo.name}');
        },
        child: Row(
          children: [
            Icon(arrowIcon, size: 16),
            SizedBox(width: 5),
            Text(text, maxLines: 1),
          ],
        ),
      );
    } else {
      var arrowIcon = Icons.link_rounded;
      var text = "Referencing with ${memo.relations.length} memos";
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/${memo.name}');
        },
        child: Row(
          children: [
            Icon(arrowIcon, size: 16),
            SizedBox(width: 5),
            Text(text, maxLines: 1),
          ],
        ),
      );
    }
  }
}

PopupMenuItemBuilder createMemoBuilder(
  BuildContext context,
  Memo memo,
  Function onDeleteClick,
) {
  return (context) {
    return <PopupMenuEntry>[
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.push_pin_outlined),
          title: Text('Pin'),
          onTap: () {
            final request = UpdateMemoRequest(name: memo.name, pinned: true);
            ApiClient.instance.updateMemo(request.name, request).then((value) {
              Navigator.pop(context);
            });
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.share_outlined),
          title: Text('Share'),
          onTap: () {
            Share.share(memo.content);
            Navigator.pop(context);
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.archive_outlined),
          title: Text('Archive'),
          onTap: () {
            final request = UpdateMemoRequest(
              name: memo.name,
              state: "ARCHIVED",
            );
            ApiClient.instance.updateMemo(request.name, request).then((value) {
              Navigator.pop(context);
            });
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red),
          title: Text(
            'Delete',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: Colors.red),
          ),
          onTap: () {
            onDeleteClick();
            Navigator.pop(context);
          },
        ),
      ),
    ];
  };
}

PopupMenuItemBuilder createMemoOptionMenu({
  required context,
  required memo,
  Function? onDeleteClick,
  Function? onPinClick,
  Function? onUnpinClick,
  Function? onArchiveClick,
  Function? onRestoreClick,
  Function? onShareClick,
  Function? onEditClick,
}) {
  return (context) {
    return <PopupMenuEntry>[
      memo.pinned
          ? PopupMenuItem(
            onTap: () => onPinClick?.call(),
            child: ListTile(
              leading: Icon(Icons.pin_drop_outlined),
              title: Text('Unpin'),
            ),
          )
          : PopupMenuItem(
            onTap: () => onUnpinClick?.call(),
            child: ListTile(
              leading: Icon(Icons.push_pin_outlined),
              title: Text('Pin'),
            ),
          ),
      if (memo.state == MemoState.normal)
        PopupMenuItem(
          onTap: () => onShareClick?.call(),
          child: ListTile(
            leading: Icon(Icons.share_outlined),
            title: Text('Share'),
          ),
        ),
      memo.state == MemoState.archived
          ? PopupMenuItem(
            onTap: () => onRestoreClick?.call(),
            child: ListTile(
              leading: Icon(Icons.restore_from_trash_outlined),
              title: Text('Restore'),
            ),
          )
          : PopupMenuItem(
            onTap: () => onArchiveClick?.call(),
            child: ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text('Archive'),
            ),
          ),
      PopupMenuItem(
        onTap: () => onDeleteClick?.call(),
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red),
          title: Text(
            'Delete',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: Colors.red),
          ),
        ),
      ),
    ];
  };
}
