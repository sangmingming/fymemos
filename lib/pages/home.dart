import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/pages/archived_memo_list_page.dart';
import 'package:fymemos/pages/memolist/memo_list_page.dart';
import 'package:fymemos/pages/memolist/memo_list_vm.dart';
import 'package:fymemos/pages/resourceslist/resources_list_page.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/result.dart';
import 'package:fymemos/widgets/statics.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';

class MemoDestination {
  const MemoDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<MemoDestination> destinations = <MemoDestination>[
  MemoDestination('Memos', Icons.workspaces_outline, Icons.workspaces_filled),
  MemoDestination(
    'Archived',
    Icons.inventory_2_outlined,
    Icons.inventory_2_rounded,
  ),
  MemoDestination(
    'Resources',
    Icons.perm_media_outlined,
    Icons.perm_media_rounded,
  ),
];

class NavigationDrawerHomePage extends StatefulWidget {
  final String? action;
  const NavigationDrawerHomePage({super.key, this.action});

  @override
  State<NavigationDrawerHomePage> createState() =>
      _NavigationDrawerHomePageState();
}

class _NavigationDrawerHomePageState extends State<NavigationDrawerHomePage>
    with Refena {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int screenIndex = 0;
  late bool showNavigationRail;
  String title = destinations[0].label;
  UserProfile? userProfile;
  UserStats? userStats;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.action == "search") {
        setState(() {
          isSearching = true;
        });
      }
    });
  }

  void handleScreenChanged(int selectedScreen) {
    print("Selected screen: $selectedScreen");
    if (isSearching) {
      ref.notifier(userMemoProvider).refresh();
    }
    setState(() {
      screenIndex = selectedScreen;
      isSearching = false;
    });
  }

  void handleDrawerScreenChanged(int selectedScreen) {
    print("Selected screen: $selectedScreen");
    handleScreenChanged(selectedScreen);
    scaffoldKey.currentState!.closeDrawer();
  }

  @override
  void didChangeDependencies() {
    showNavigationRail = MediaQuery.of(context).size.width >= 500;
    super.didChangeDependencies();
  }

  Widget buildWithNavigationDrawer(BuildContext context) {
    return PopScope(
      canPop: !isSearching,
      onPopInvokedWithResult: (didPop, result) {
        setState(() {
          isSearching = false;
        });
        ref.notifier(userMemoProvider).refresh();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: _buildAppBar(context),
        body: SafeArea(bottom: false, top: false, child: getCurrentPage()),
        drawer: NavigationDrawer(
          onDestinationSelected: handleDrawerScreenChanged,
          selectedIndex: screenIndex,
          children: _buildNavigationItems(context),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    final userData = context.watch(authProvider);
    return <Widget>[
      UserStatisticWidget(
        user: userData.data?.profile,
        userStats: userData.data?.stats,
      ),
      ...destinations.map(
        (MemoDestination destination) => NavigationDrawerDestination(
          label: Text(destination.label),
          icon: Icon(destination.icon),
          selectedIcon: Icon(destination.selectedIcon),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
        child: Divider(),
      ),
      ...userData.data?.stats.tagCount.entries
              .map(
                (entity) => ListTile(
                  onTap: () {
                    context.push("/tags/${entity.key}");
                  },
                  leading: Icon(Icons.tag),
                  title: Row(
                    children: [
                      Text(entity.key),
                      SizedBox(width: 4),
                      Text(
                        "(${entity.value})",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text("Rename"),
                          onTap: () {
                            _renameTag(context, entity.key);
                          },
                        ),
                        PopupMenuItem(
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            _deleteTag(context, entity.key);
                          },
                        ),
                      ];
                    },
                    icon: Icon(Icons.more_horiz_rounded),
                  ),
                ),
              )
              .toList() ??
          [],
    ];
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading:
          isSearching
              ? IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = false;
                  });
                  ref.notifier(userMemoProvider).refresh();
                },
                icon: Icon(Icons.arrow_back),
              )
              : null,
      title: AnimatedSize(
        duration: Duration(milliseconds: 300),
        child:
            isSearching
                ? TextField(
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search Memos...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ), // 移除边框
                    isDense: true,
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.only(left: 0),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                        });
                        ref.notifier(userMemoProvider).refresh();
                      },
                    ),
                  ),
                  onChanged: (value) {
                    ref.notifier(userMemoProvider).search(value);
                  },
                )
                : Text(destinations[screenIndex].label),
      ),
      actions: [
        if (screenIndex == 0 && !isSearching)
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ),
      ],
    );
  }

  Widget buildWithNavigationRail(BuildContext context) {
    return PopScope(
      canPop: !isSearching,
      onPopInvokedWithResult: (didPop, result) {
        setState(() {
          isSearching = false;
        });
        ref.notifier(userMemoProvider).refresh();
      },
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          bottom: false,
          top: false,
          child: Row(
            children: <Widget>[
              NavigationDrawer(
                backgroundColor: Theme.of(context).canvasColor,
                onDestinationSelected: handleScreenChanged,
                selectedIndex: screenIndex,
                children: _buildNavigationItems(context),
              ),
              Expanded(
                child: Scaffold(
                  appBar: _buildAppBar(context),
                  body: getCurrentPage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCurrentPage() {
    if (screenIndex == 0) {
      return MemoListPage();
    } else if (screenIndex == 1) {
      return ArchivedMemoListPage();
    } else {
      return ResourcesListPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return showNavigationRail
        ? buildWithNavigationRail(context)
        : buildWithNavigationDrawer(context);
  }
}
