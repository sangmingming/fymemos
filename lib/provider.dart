import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/model/memos.dart';
import 'package:fymemos/model/users.dart';
import 'package:refena_flutter/refena_flutter.dart';

final memoDetailsProvider = FutureProvider.family<Memo, String>((
  ref,
  id,
) async {
  return ApiClient.instance.getMemoDirect(id);
});

class AuthInfo {
  final String userId;
  final UserProfile profile;
  final UserStats stats;
  AuthInfo(this.userId, this.profile, this.stats);
}

final authProvider = FutureProvider((ref) async {
  final profile = await ApiClient.instance.getAuthStatusDirect();
  final userId = await SharedPreferencesService.instance.fetchUserDirect();
  if (userId == null) {
    SharedPreferencesService.instance.saveUser(profile.name);
  }
  final stats = await ApiClient.instance.getUserStatsDirect(profile.name);
  return AuthInfo(profile.name, profile, stats);
});
