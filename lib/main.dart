import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/pages/archived_memo_list_page.dart';
import 'package:fymemos/pages/login_page.dart';
import 'package:fymemos/pages/memo_detail_page.dart';
import 'package:fymemos/pages/memo_list_page.dart';
import 'package:fymemos/pages/resources_list_page.dart';
import 'package:fymemos/pages/tag_memo_list_page.dart';
import 'package:fymemos/repo/repository.dart';
import 'package:fymemos/widgets/statics.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.green);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            fontFamily: "Noto",
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: "Noto",
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system, // Use system theme mode
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final uri = Uri.parse(settings.name!);
            print(
              "jump uri: $uri  first : ${uri.pathSegments.first} count: ${uri.pathSegments.length}",
            );
            if (uri.pathSegments.length == 2 &&
                uri.pathSegments.first == "memos") {
              return MaterialPageRoute(
                builder: (context) {
                  return MemoDetailPage(resourceName: uri.pathSegments[1]);
                },
              );
            } else if (uri.pathSegments.length == 2 &&
                uri.pathSegments.first == "tags") {
              return MaterialPageRoute(
                builder: (context) {
                  return TagMemoListPage(memoTag: uri.pathSegments[1]);
                },
              );
            }
            return MaterialPageRoute(
              builder: (context) {
                return const CheckLoginPage();
              },
            );
          },
          routes: {
            '/': (context) => const CheckLoginPage(),
            '/home': (context) => const NavigationDrawerHomePage(),
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}

class CheckLoginPage extends StatefulWidget {
  const CheckLoginPage({super.key});

  @override
  State<CheckLoginPage> createState() => _CheckLoginPageState();
}

class _CheckLoginPageState extends State<CheckLoginPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final accessToken = prefs.getString('accessToken');

    if (baseUrl != null && accessToken != null) {
      initDio(baseUrl: baseUrl, token: accessToken);
      getAuthStatus().then((user) {
        prefs.setString("user", user.name);
        Navigator.of(context).pushReplacementNamed('/home');
      });
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ...userStats?.tagCount.entries
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
