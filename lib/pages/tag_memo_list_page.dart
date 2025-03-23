import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/provider.dart';
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

  void _renameTag(BuildContext context, String tag) async {
    final TextEditingController controller = TextEditingController(text: tag);
    final newTag = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rename Tag"),
          content: TextField(
            autofocus: true,
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'New tag name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text("Finish"),
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
        ).showSnackBar(SnackBar(content: Text("Tag renamed")));
        ref.rebuild(authProvider);
      } else if (renameResult is Error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(renameResult.error.toString())));
      }
    }
  }

  void _deleteTag(BuildContext context, String tag) async {
    //show confirm dialog ,then delete tag
    bool? r = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Tag"),
          content: Text(
            "Are you sure you want to delete this tag? This will remove all memos related to #$tag.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Delete"),
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
        ).showSnackBar(SnackBar(content: Text("Tag deleted")));
        ref.rebuild(authProvider);
      } else if (deleteResult is Error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(deleteResult.error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memoTag),
        actions: [
          IconButton(
            onPressed: () {
              _renameTag(context, widget.memoTag);
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              _deleteTag(context, widget.memoTag);
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
