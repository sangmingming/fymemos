import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/model/memos.dart';
import 'package:refena_flutter/refena_flutter.dart';

final memoDetailsProvider = FutureProvider.family<Memo, String>((
  ref,
  id,
) async {
  return ApiClient.instance.getMemoDirect(id);
});
