import 'package:flutter/material.dart';
import 'package:fymemos/repo/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', baseUrl);
    await prefs.setString('accessToken', accessToken);
    initDio(baseUrl: baseUrl, token: accessToken);
    final user = await getAuthStatus();
    await prefs.setString("user", user.name);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
            FilledButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}
