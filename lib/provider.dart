import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:refena_flutter/refena_flutter.dart';

final memoDetailsProvider = FutureProvider.family<Memo, String>((
  ref,
  id,
) async {
  return ApiClient.instance.getMemoDirect(id);
});

final authProvider = FutureProvider((ref) async {
  return await SharedPreferencesService.instance.fetchUserDirect();
});
