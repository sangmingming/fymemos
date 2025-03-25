import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/generated/l10n.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with Refena {
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _accessTokenController = TextEditingController();

  void _login() async {
    final baseUrl = _baseUrlController.text;
    final accessToken = _accessTokenController.text;

    if (baseUrl.isEmpty || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Base URL and Access Token cannot be empty')),
      );
      return;
    }

    final prefs = SharedPreferencesService.instance;
    await prefs.saveBaseUrl(baseUrl);
    await prefs.saveToken(accessToken);

    final apiClient = ApiClient.instance;
    apiClient.initDio(baseUrl: baseUrl, token: accessToken);
    final userResult = await apiClient.getAuthStatus();

    switch (userResult) {
      case Ok():
        context.rebuild(authProvider);
        prefs.saveUser(userResult.value.name);
        context.pushReplacement('/');
        break;
      case Error():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${userResult.error}')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).title_login)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please enter your Memos Host and accessToken"),
            SizedBox(height: 16),
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(labelText: 'Base URL'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _accessTokenController,
              decoration: InputDecoration(labelText: 'Access Token'),
            ),
            SizedBox(height: 16),
            Expanded(child: Container()),
            FilledButton(
              onPressed: _login,
              child: Text(S.of(context).button_login),
            ),
          ],
        ),
      ),
    );
  }
}
