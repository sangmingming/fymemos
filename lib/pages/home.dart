import 'package:flutter/material.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/pages/archived_memo_list_page.dart';
import 'package:fymemos/pages/memolist/memo_list_page.dart';
import 'package:fymemos/pages/memolist/memo_list_vm.dart';
import 'package:fymemos/pages/resourceslist/resources_list_page.dart';
import 'package:fymemos/pages/tag_memo_list_page.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/l10n.dart';
import 'package:fymemos/widgets/statics.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:share_handler/share_handler.dart';

class MemoDestination {
  const MemoDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<MemoDestination> destinations = <MemoDestination>[
  MemoDestination(
    'title_home',
    Icons.workspaces_outline,
    Icons.workspaces_filled,
  ),
  MemoDestination(
    'title_archived',
    Icons.inventory_2_outlined,
    Icons.inventory_2_rounded,
  ),
  MemoDestination(
    'title_resources',
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
  UserProfile? userProfile;
  UserStats? userStats;
  bool isSearching = false;
  SharedMedia? sharedMedia;

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
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final handler = ShareHandlerPlatform.instance;
    sharedMedia = await handler.getInitialSharedMedia();

    handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      sharedMedia?.attachments?.forEach((element) {
        print("object ${element?.path}");
      });
      final image = sharedMedia?.attachments?.firstWhere(
        (element) => element?.type == SharedAttachmentType.image,
      );

      print("object image ${image?.path}");
      final imageFile = image?.path ?? sharedMedia?.imageFilePath;
      print("object image path ${imageFile}");
      context.go(
        "/create_memo",
        extra: {"content": media.content, "image": imageFile},
      );
    });
    if (!mounted) return;
    if (sharedMedia != null) {
      final image = sharedMedia?.attachments?.firstWhere(
        (element) => element?.type == SharedAttachmentType.image,
      );
      sharedMedia?.attachments?.forEach((element) {
        print("init object ${element?.path}");
      });
      print("init object image ${sharedMedia?.imageFilePath}");
      final imageFile = image?.path ?? sharedMedia?.imageFilePath;

      context.go(
        "/create_memo",
        extra: {"content": sharedMedia!.content, "image": imageFile},
      );
    }
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
          label: Text(context.intl[destination.label]),
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
                          child: Text(context.intl.edit_rename),
                          onTap: () {
                            renameTag(context, entity.key);
                          },
                        ),
                        PopupMenuItem(
                          child: Text(
                            context.intl.edit_delete,
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            deleteTag(context, entity.key);
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
                    hintText: context.intl.hint_search,
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
                : Text(context.intl[destinations[screenIndex].label]),
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
