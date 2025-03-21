import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/pages/archived_memo_list_page.dart';
import 'package:fymemos/pages/memolist/memo_list_page.dart';
import 'package:fymemos/pages/resourceslist/resources_list_page.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/result.dart';
import 'package:fymemos/widgets/statics.dart';
import 'package:refena_flutter/refena_flutter.dart';

class CheckLoginPage extends StatefulWidget {
  const CheckLoginPage({super.key});

  @override
  State<CheckLoginPage> createState() => _CheckLoginPageState();
}

class _CheckLoginPageState extends State<CheckLoginPage> {
  @override
  void initState() {
    super.initState();
  }

  void _checkLogin() async {
    final sp = SharedPreferencesService.instance;
    final baseUrl = await sp.fetchBaseUrl();
    final accessToken = await sp.fetchToken();
    final apiClient = ApiClient.instance;

    if (baseUrl is Ok<String?> && accessToken is Ok<String?>) {
      if (baseUrl.value == null || accessToken.value == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      apiClient.initDio(baseUrl: baseUrl.value, token: accessToken.value);

      final data = context.watch(authProvider);
      if (data.hasData) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (data.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status check failed: ${data.error}')),
        );
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkLogin();
    return Scaffold(body: Center(child: CircularProgressIndicator()));
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

class _NavigationDrawerHomePageState extends State<NavigationDrawerHomePage>
    with Refena {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int screenIndex = 0;
  late bool showNavigationRail;
  String title = destinations[0].label;
  UserProfile? userProfile;
  UserStats? userStats;

  @override
  void initState() {
    super.initState();
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
                    Navigator.of(context).pushNamed("/tags/${entity.key}");
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
                  trailing: Icon(Icons.more_horiz_rounded),
                ),
              )
              .toList() ??
          [],
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
