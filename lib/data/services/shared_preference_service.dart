import 'package:fymemos/utils/result.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _tokenKey = 'accessToken';
  static const _baseUrlKey = 'baseUrl';
  static const _usernameKey = 'user';

  static final SharedPreferencesService _instance = SharedPreferencesService();

  static SharedPreferencesService get instance => _instance;

  final _log = Logger('SharedPreferencesService');

  Future<Result<String?>> fetchToken() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got token from SharedPreferences');
      return Result.ok(sharedPreferences.getString(_tokenKey));
    } on Exception catch (e) {
      _log.warning('Failed to get token', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveToken(String? token) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (token == null) {
        _log.finer('Removed token');
        await sharedPreferences.remove(_tokenKey);
      } else {
        _log.finer('Replaced token');
        await sharedPreferences.setString(_tokenKey, token);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set token', e);
      return Result.error(e);
    }
  }

  Future<Result<String?>> fetchBaseUrl() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got base URL from SharedPreferences');
      return Result.ok(sharedPreferences.getString(_baseUrlKey));
    } on Exception catch (e) {
      _log.warning('Failed to get base URL', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveBaseUrl(String? baseUrl) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (baseUrl == null) {
        _log.finer('Removed base URL');
        await sharedPreferences.remove(_baseUrlKey);
      } else {
        _log.finer('Replaced base URL');
        await sharedPreferences.setString(_baseUrlKey, baseUrl);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set base URL', e);
      return Result.error(e);
    }
  }

  Future<Result<String?>> fetchUser() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got user from SharedPreferences');
      return Result.ok(sharedPreferences.getString(_usernameKey));
    } on Exception catch (e) {
      _log.warning('Failed to get user', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveUser(String? user) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (user == null) {
        _log.finer('Removed user');
        await sharedPreferences.remove(_usernameKey);
      } else {
        _log.finer('Replaced user');
        await sharedPreferences.setString(_usernameKey, user);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set user', e);
      return Result.error(e);
    }
  }
}
