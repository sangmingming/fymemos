import 'package:flutter/material.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/pages/create_memo_page.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:intl/intl.dart';
import 'repo/repository.dart';

void main() {
  // Intl.defaultLocale = 'zh_CN';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initDio();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        fontFamily: "Noto",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Memos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Memo> memo = List.empty();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  String? _nextPageToken;

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoadingMore && _nextPageToken != null) {
          _isLoadingMore = true;
          loadMoreData(_nextPageToken!);
        }
      }
    });
  }

  Future<void> loadData() async {
    MemosResponse r = await fetchMemos();
    if (r.memos != null) {
      print("${r.nextPageToken}");
      setState(() {
        memo = r.memos!;
        _nextPageToken = r.nextPageToken;
      });
    }
  }

  Future<void> _refreshData() async {
    await loadData();
  }

  void loadMoreData(String pageToken) async {
    if (_nextPageToken == null) return;

    setState(() {
      _isLoadingMore = true;
    });
    MemosResponse r = await fetchMemos(pageToken: pageToken);
    if (r.memos != null) {
      print("${r.nextPageToken}");
      setState(() {
        memo.addAll(r.memos!);
        if (r.nextPageToken != null && r.nextPageToken!.isNotEmpty) {
          _nextPageToken = r.nextPageToken;
        } else {
          _nextPageToken = null;
        }
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _nextPageToken = null;
      });
    }
  }

  void _createMemo() async {
    final newMemo = await Navigator.of(
      context,
    ).push<Memo?>(MaterialPageRoute(builder: (context) => CreateMemoPage()));
    if (newMemo != null) {
      setState(() {
        memo.insert(0, newMemo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: memo.length + 1,
          itemBuilder: (context, index) {
            if (index == memo.length) {
              if (_isLoadingMore) {
                return Center(child: CircularProgressIndicator());
              } else if (_nextPageToken == null) {
                return Center(child: Text('No more data'));
              } else {
                return SizedBox.shrink(); // Empty space when not loading more and not at the end
              }
            } else {
              return MemoItem(memo: memo[index]);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        tooltip: '创作',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
