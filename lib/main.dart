import 'package:flutter/material.dart';
import 'package:fymemos/config/init.dart';
import 'package:fymemos/data/services/settings_provider.dart';
import 'package:fymemos/generated/l10n.dart';
import 'package:fymemos/pages/bottom_sheet_page.dart';
import 'package:fymemos/pages/home.dart';
import 'package:fymemos/pages/login_page.dart';
import 'package:fymemos/pages/memodetail/memo_detail_page.dart';
import 'package:fymemos/pages/memoedit/create_memo_page.dart';
import 'package:fymemos/pages/settings/settings_page.dart';
import 'package:fymemos/pages/tag_memo_list_page.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/ui/core/theme/dynamic_colors.dart';
import 'package:fymemos/ui/core/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main(List<String> args) async {
  final RefenaContainer container;
  try {
    container = await preinit(args);
  } catch (e, stackTrace) {
    return;
  }
  runApp(RefenaScope.withContainer(container: container, child: const MyApp()));
}

final _router = GoRouter(
  redirect: (context, state) async {
    try {
      final authState = await context.future(authProvider);
    } catch (e) {
      return '/login';
    }
    print("redirect: ${state.fullPath} ${state.uri}");

    return null;
  },
  routes: [
    GoRoute(
      path: "/search_memo",
      redirect: (context, state) {
        return '/?action=search';
      },
    ),
    GoRoute(
      path: '/',
      builder:
          (context, state) => NavigationDrawerHomePage(
            action: state.uri.queryParameters['action'],
          ),
      routes: [
        ShellRoute(
          pageBuilder:
              (context, state, child) =>
                  BottomSheetPage(child: child, key: state.pageKey),
          routes: [
            GoRoute(
              path: 'create_memo',
              builder:
                  (context, state) => CreateMemoPage(
                    params:
                        state.extra is Map<String, String?>
                            ? (state.extra as Map<String, String?>)
                            : <String, String?>{},
                  ),
            ),
          ],
        ),
        GoRoute(
          path: 'memos/:memoId',
          builder:
              (context, state) => MemoDetailPage(
                resourceName: state.pathParameters['memoId'] ?? '',
              ),
        ),
        GoRoute(
          path: 'tags/:tagId',
          builder:
              (context, state) =>
                  TagMemoListPage(memoTag: state.pathParameters['tagId'] ?? ''),
        ),
        GoRoute(path: 'login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
  initialLocation: '/',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;
    final dynamicColors = ref.watch(dynamicColorsProvider);
    final (themMode, colorMode) = ref.watch(
      settingsProvider.select((s) => (s.themeMode, s.colorMode)),
    );
    return MaterialApp.router(
      title: 'FyMemos',
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('zh'),
        Locale('zh', 'CN'), // Chinese
      ],
      theme: getTheme(Brightness.light, dynamicColors, colorMode),
      darkTheme: getTheme(Brightness.dark, dynamicColors, colorMode),
      themeMode: themMode, // Use system theme mode
      routerConfig: _router,
    );
  }
}
