import 'package:flutter/material.dart';
import 'package:fymemos/config/init.dart';
import 'package:fymemos/pages/home.dart';
import 'package:fymemos/pages/login_page.dart';
import 'package:fymemos/pages/memodetail/memo_detail_page.dart';
import 'package:fymemos/pages/settings_page.dart';
import 'package:fymemos/pages/tag_memo_list_page.dart';
import 'package:fymemos/ui/core/theme/dynamic_colors.dart';
import 'package:fymemos/ui/core/theme/theme.dart';
import 'package:refena_flutter/refena_flutter.dart';

Future<void> main(List<String> args) async {
  final RefenaContainer container;
  try {
    container = await preinit(args);
  } catch (e, stackTrace) {
    return;
  }
  runApp(RefenaScope.withContainer(container: container, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;
    final dynamicColors = ref.watch(dynamicColorsProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: getTheme(Brightness.light, dynamicColors),
      darkTheme: getTheme(Brightness.dark, dynamicColors),
      themeMode: ThemeMode.system, // Use system theme mode
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        print(
          "jump uri: $uri  first : ${uri.pathSegments.first} count: ${uri.pathSegments.length}",
        );
        if (uri.pathSegments.length == 2 && uri.pathSegments.first == "memos") {
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
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
