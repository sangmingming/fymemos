import 'package:flutter/material.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/pages/archived_memo_list_page.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/pages/memo_list_page.dart';
import 'package:fymemos/pages/resources_list_page.dart';
import 'package:fymemos/repo/repository.dart';
import 'package:fymemos/widgets/statics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    initDio();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Noto",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NavigationDrawerHomePage(),
    );
  }
}

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
  const NavigationDrawerHomePage({super.key});

  @override
  State<NavigationDrawerHomePage> createState() =>
      _NavigationDrawerHomePageState();
}

class _NavigationDrawerHomePageState extends State<NavigationDrawerHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int screenIndex = 0;
  late bool showNavigationRail;
  String title = destinations[0].label;
  UserProfile? userProfile;
  UserStats? userStats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await getAuthStatus();
    final stats = await getUserStats(user.name);
    print(user.name);
    print(stats.name);

    setState(() {
      userProfile = user;
      userStats = stats;
    });
  }

  void handleScreenChanged(int selectedScreen) {
    print("Selected screen: $selectedScreen");
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void handleDrawerScreenChanged(int selectedScreen) {
    print("Selected screen: $selectedScreen");
    setState(() {
      screenIndex = selectedScreen;
    });
    scaffoldKey.currentState!.closeDrawer();
  }

  @override
  void didChangeDependencies() {
    showNavigationRail = MediaQuery.of(context).size.width >= 500;
    super.didChangeDependencies();
  }

  Widget buildWithNavigationDrawer(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(destinations[screenIndex].label)),
      body: SafeArea(bottom: false, top: false, child: getCurrentPage()),
      drawer: NavigationDrawer(
        onDestinationSelected: handleDrawerScreenChanged,
        selectedIndex: screenIndex,
        children: _buildNavigationItems(context),
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    return <Widget>[
      UserStatisticWidget(user: userProfile, userStats: userStats),
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
    ];
  }

  Widget buildWithNavigationRail(BuildContext context) {
    return Scaffold(
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

            Expanded(child: getCurrentPage()),
          ],
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
