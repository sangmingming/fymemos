import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/pages/memolist/memo_list_vm.dart';
import 'package:fymemos/utils/l10n.dart';
import 'package:fymemos/widgets/memo_content.dart';
import 'package:fymemos/widgets/related_memo.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: GestureDetector(
        onTap: () => showImageDialog(context, resource),
        child: Hero(
          tag: resource.name,
          child: CachedNetworkImage(
            imageUrl: resource.thumbnailUrl,
            fit: fit,
            httpHeaders: ApiClient.instance.requestHeaders,
          ),
        ),
      ),
    );
  }
}

class MemoItem extends StatelessWidget {
  const MemoItem({required this.memo, this.isDetail = false, super.key});
  final Memo memo;
  final bool isDetail;

  Widget _buildMemoContent(BuildContext context, Memo memo, bool isDetail) {
    return Padding(
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
                  itemBuilder: createMemoOptionMenu(
                    context: context,
                    memo: memo,
                    onArchiveClick: () async {
                      await context
                          .notifier(userMemoProvider)
                          .archiveMemo(memo);
                    },
                    onRestoreClick: () async {
                      await context
                          .notifier(userMemoProvider)
                          .restoreMemo(memo);
                    },
                    onPinClick: () async {
                      await context.notifier(userMemoProvider).pinMemo(memo);
                    },
                    onUnpinClick: () async {
                      await context.notifier(userMemoProvider).unpinMemo(memo);
                    },
                    onDeleteClick: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              content: Text(context.intl.delete_memo_confirm),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(context.intl.button_cancel),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onError,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(context.intl.edit_delete),
                                ),
                              ],
                            ),
                      );

                      if (confirmed == true && context.mounted) {
                        await context
                            .notifier(userMemoProvider)
                            .deleteMemo(memo);
                      }
                    },
                  ),
                  icon: Icon(Icons.more_horiz_rounded),
                ),
            ],
          ),
          SizedBox(height: 5),
          MemoContent(
            nodes: memo.nodes,
            onCheckClicked: () => onCheckChecked(context, memo),
          ),
          SizedBox(height: 5),
          if (memo.resources.isNotEmpty)
            MemoResourceCard(
              resources: memo.resources,
              onResourceTap: (resource) {
                showImageDialog(context, resource);
              },
            ),
          _buildRelatedMemoCards(context, memo, isDetail),
        ],
      ),
    );
  }

  Widget _buildRelatedMemoCards(
    BuildContext context,
    Memo memo,
    bool isDetail,
  ) {
    if (memo.relations.isNotEmpty && !isDetail) {
      return RelatedMemoSimpleWidget(memo: memo);
    } else if (memo.relations.isNotEmpty && isDetail) {
      return Column(
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
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card.filled(
      borderOnForeground: true,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      shape: RoundedRectangleBorder(
        // 新增边框形状
        side: BorderSide(
          color:
              memo.pinned ? colorScheme.outline : colorScheme.surface, // 使用主题颜色
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // 保持与卡片原有圆角一致
      ),
      child: _buildMemoContent(context, memo, isDetail),
    );
  }
}

void onCheckChecked(BuildContext context, Memo memo) async {
  await context.notifier(userMemoProvider).updateMemo(memo);
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
      var text = context.intl.memo_reference_one(
        memo.relations.first.relatedMemo.snippet,
      );
      if (memo.relations.first.memo.name != memo.name) {
        arrowIcon = Icons.south_east_rounded;
        text = context.intl.memo_reference_by_one(
          memo.relations.first.relatedMemo.snippet,
        );
      }
      return GestureDetector(
        onTap: () {
          context.go('/${memo.name}');
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
      var text = context.intl.memo_references(memo.relations.length);
      return GestureDetector(
        onTap: () {
          context.go('/${memo.name}');
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
            onTap: () => onUnpinClick?.call(),
            child: ListTile(
              leading: Icon(Icons.pin_drop_outlined),
              title: Text(context.intl.edit_Unpin),
            ),
          )
          : PopupMenuItem(
            onTap: () => onPinClick?.call(),
            child: ListTile(
              leading: Icon(Icons.push_pin_outlined),
              title: Text(context.intl.edit_pin),
            ),
          ),
      if (memo.state == MemoState.normal)
        PopupMenuItem(
          onTap: () => onShareClick?.call(),
          child: ListTile(
            leading: Icon(Icons.share_outlined),
            title: Text(context.intl.share),
          ),
        ),
      memo.state == MemoState.archived
          ? PopupMenuItem(
            onTap: () => onRestoreClick?.call(),
            child: ListTile(
              leading: Icon(Icons.restore_from_trash_outlined),
              title: Text(context.intl.edit_restore),
            ),
          )
          : PopupMenuItem(
            onTap: () => onArchiveClick?.call(),
            child: ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text(context.intl.edit_archive),
            ),
          ),
      PopupMenuItem(
        onTap: () => onDeleteClick?.call(),
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red),
          title: Text(
            context.intl.edit_delete,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: Colors.red),
          ),
        ),
      ),
    ];
  };
}
