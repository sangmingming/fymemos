import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/resources.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ResourcesVm {
  final AsyncValue<List<MemoResource>> resources;
  final Function refresh;
  ResourcesVm({required this.resources, required this.refresh});
}

final resourcesVmProvider = ViewProvider<ResourcesVm>((ref) {
  final res = ref.watch(resourcesListProvider);
  print("build recources VM");
  return ResourcesVm(
    resources: res,
    refresh: () {
      ref.rebuild(resourcesListProvider);
    },
  );
});

final resourcesListProvider = FutureProvider<List<MemoResource>>((ref) async {
  return await ApiClient.instance.fetchMemoResources();
});
