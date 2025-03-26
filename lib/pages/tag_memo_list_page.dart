import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/l10n.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/utils/result.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:refena_flutter/refena_flutter.dart';

class TagMemoListPage extends StatefulWidget {
  final String memoTag;
  const TagMemoListPage({super.key, required this.memoTag});

  @override
  State<TagMemoListPage> createState() => _TagMemoListPageState();
}

class _TagMemoListPageState extends State<TagMemoListPage> with Refena {
  LoadState<List<Memo>> memo = LoadState.loading();
  List<Memo> _memoData = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  String? _nextPageToken;
  String? filter;

  @override
  void initState() {
    super.initState();
    filter = "tag in [\"${widget.memoTag}\"]";
    loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        loadMoreData();
      }
    });
  }

  Future<void> loadData() async {
    final sp = SharedPreferencesService.instance;
    final user = await sp.fetchUser();
    if (user is Error) {
      return;
    }
    final uid = (user as Ok<String?>).value!;

    final r = await ApiClient.instance.fetchUserMemos(
      user: uid,
      filter: filter,
    );
    switch (r) {
      case Loading():
        setState(() {
          memo = LoadState.loading();
        });
      case ErrorState():
        setState(() {
          memo = LoadState.error(r.error);
        });
      case Success():
        setState(() {
          if (r.value.memos == null || r.value.memos!.isEmpty) {
            _nextPageToken = null;
          } else {
            _memoData.addAll(r.value.memos!);
            memo = LoadState.success(_memoData);
            _nextPageToken = r.value.nextPageToken;
          }
        });
    }
  }

  Future<void> loadMoreData() async {
    if (_nextPageToken == null) return;

    setState(() {
      _isLoadingMore = true;
    });
    final sp = SharedPreferencesService.instance;
    final user = await sp.fetchUser();
    if (user is Error) {
      return;
    }
    final uid = (user as Ok<String?>).value!;

    final r = await ApiClient.instance.fetchUserMemos(
      user: uid,
      pageToken: _nextPageToken!,
      filter: filter,
    );
    switch (r) {
      case Loading():
        setState(() {
          memo = LoadState.loading();
        });
      case ErrorState():
        setState(() {
          memo = LoadState.error(r.error);
        });
      case Success():
        setState(() {
          if (r.value.memos == null || r.value.memos!.isEmpty) {
            _nextPageToken = null;
          } else {
            _memoData.addAll(r.value.memos!);
            memo = LoadState.success(_memoData);
            _nextPageToken = r.value.nextPageToken;
          }
        });
    }
  }

  Future<void> _refreshData() async {
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memoTag),
        actions: [
          IconButton(
            onPressed: () {
              renameTag(context, widget.memoTag);
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              deleteTag(context, widget.memoTag);
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildResult(memo),
      ),
    );
  }

  Widget _buildResult(LoadState<List<Memo>> result) {
    return buildPage(result, (item) {
      return _buildList(item);
    });
  }

  Widget _buildList(List<Memo> memos) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: memos.length + 1,
      itemBuilder: (context, index) {
        if (index == memos.length) {
          if (_isLoadingMore) {
            return Center(child: CircularProgressIndicator());
          } else if (_nextPageToken == null) {
            return Center(child: Text('No more data'));
          } else {
            return SizedBox.shrink(); // Empty space when not loading more and not at the end
          }
        } else {
          return MemoItem(memo: memos[index]);
        }
      },
    );
  }
}

void renameTag(BuildContext context, String tag) async {
  final TextEditingController controller = TextEditingController(text: tag);
  final newTag = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.intl.title_rename_tag),
        content: TextField(
          autofocus: true,
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: context.intl.hint_new_tag,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.intl.button_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            child: Text(context.intl.button_finish),
          ),
        ],
      );
    },
  );
  if (newTag != null) {
    final renameResult = await ApiClient.instance.renameTag(tag, newTag);
    if (renameResult is Ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.intl.msg_tag_rename)));
      context.rebuild(authProvider);
    } else if (renameResult is Error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(renameResult.error.toString())));
    }
  }
}

void deleteTag(BuildContext context, String tag) async {
  //show confirm dialog ,then delete tag
  bool? r = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.intl.title_delete_tag),
        content: Text(context.intl.delete_tag_confirm(tag)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(context.intl.button_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(context.intl.edit_delete),
          ),
        ],
      );
    },
  );

  if (r == true) {
    final deleteResult = await ApiClient.instance.deleteTag(tag);
    if (deleteResult is Ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.intl.msg_tag_delete)));
      context.ref.rebuild(authProvider);
    } else if (deleteResult is Error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(deleteResult.error.toString())));
    }
  }
}
