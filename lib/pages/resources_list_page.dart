import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/repo/repository.dart';

class ResourcesListPage extends StatefulWidget {
  const ResourcesListPage({Key? key}) : super(key: key);

  @override
  _ResourcesListPageState createState() => _ResourcesListPageState();
}

class _ResourcesListPageState extends State<ResourcesListPage> {
  List<MemoResource> resources = [];
  Map<String, String> imageHeaders = {"Authorization": "Bearer $token"};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    List<MemoResource> newResources = await fetchMemoResources();
    setState(() {
      resources = newResources;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    int count = 2;
    if (screenWidth > 500) {
      count = (screenWidth - 300) ~/ 150;
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: MasonryGridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          itemCount: resources.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Image.network(
              resources[index].thumbnailUrl,
              headers: imageHeaders,
            );
          },
        ),
      ),
    );
  }
}
