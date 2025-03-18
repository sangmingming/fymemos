import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fymemos/model/resources.dart';
import 'package:fymemos/pages/resourceslist/resource_vm.dart';
import 'package:fymemos/utils/load_state.dart';
import 'package:fymemos/widgets/memo.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ResourcesListPage extends StatelessWidget {
  const ResourcesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      provider: (context) => resourcesVmProvider,
      init: (context) {},
      builder: (context, vm) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => vm.refresh(),
            child: _buildResult(context, vm.resources),
          ),
        );
      },
    );
  }

  Widget _buildResult(
    BuildContext context,
    AsyncValue<List<MemoResource>> result,
  ) {
    var screenWidth = MediaQuery.of(context).size.width;
    int count = 2;
    if (screenWidth > 500) {
      count = (screenWidth - 300) ~/ 150;
    }
    return buildAsyncDataPage(result, (item) {
      return MasonryGridView.count(
        crossAxisCount: count,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        itemCount: item.length,
        itemBuilder: (context, index) {
          return MemoImageItem(resource: item[index]);
        },
      );
    });
  }
}
