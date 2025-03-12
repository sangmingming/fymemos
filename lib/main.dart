import 'package:flutter/material.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/pages/memo_list_page.dart';
import 'package:fymemos/repo/repository.dart';

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
  MemoDestination('Resources', Icons.image_outlined, Icons.image_rounded),
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
  late bool showNavigationDrawer;

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void openDrawer() {
    scaffoldKey.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: NavigationRail(
                minWidth: 50,
                extended: true,
                destinations:
                    destinations.map((MemoDestination destination) {
                      return NavigationRailDestination(
                        label: Text(destination.label),
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                      );
                    }).toList(),
                selectedIndex: screenIndex,
                useIndicator: true,
                onDestinationSelected: (int index) {
                  setState(() {
                    screenIndex = index;
                  });
                },
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Page Index = $screenIndex'),
                  ElevatedButton(
                    onPressed: openDrawer,
                    child: const Text('Open Drawer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      drawer: NavigationDrawer(
        onDestinationSelected: handleScreenChanged,
        selectedIndex: screenIndex,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Header',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...destinations.map((MemoDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
            );
          }),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
