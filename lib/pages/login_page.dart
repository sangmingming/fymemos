import 'package:flutter/material.dart';
import 'package:fymemos/data/services/api/api_client.dart';
import 'package:fymemos/data/services/shared_preference_service.dart';
import 'package:fymemos/generated/l10n.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/pages/memolist/memo_list_vm.dart';
import 'package:fymemos/provider.dart';
import 'package:fymemos/utils/l10n.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loginWithToken = true;
  bool obscurePassword = true;

  void _login() async {
    if (loginWithToken) {
      _loginWithToken();
    } else {
      _loginWithUserNameAndPassword();
    }
  }

  void _loginWithToken() async {
    String baseUrl = _baseUrlController.text;
    final accessToken = _accessTokenController.text;

    if (baseUrl.isEmpty || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Base URL and Access Token cannot be empty')),
      );
      return;
    }
    if (baseUrl.startsWith("http://")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Http is not safe, please use a https host')),
      );
      return;
    }
    if (!baseUrl.startsWith("https://")) {
      baseUrl = "https://$baseUrl";
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
        context.redux(userMemoProvider).dispatch(RefreshMemoAction());
        context.pushReplacement('/');
        break;
      case Error():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${userResult.error}')),
        );
        break;
    }
  }

  void _loginWithUserNameAndPassword() async {
    String baseUrl = _baseUrlController.text;
    final userName = _usernameController.text;
    final password = _passwordController.text;
    if (baseUrl.isEmpty || userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Host and Account info cannot be empty')),
      );
      return;
    }
    if (baseUrl.startsWith("http://")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Http is not safe, please use a https host')),
      );
      return;
    }
    if (!baseUrl.startsWith("https://")) {
      baseUrl = "https://$baseUrl";
    }

    Result<UserProfile> result = await ApiClient.instance.signIn(
      baseUrl,
      userName,
      password,
    );
    if (Result is Error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${(result as Error).error.toString()}'),
        ),
      );
      return;
    }
    final user = (result as Ok<UserProfile>).value;
    final prefs = SharedPreferencesService.instance;
    await prefs.saveBaseUrl(baseUrl);
    await prefs.saveToken(user.token);
    await prefs.saveUser(user.name);
    ApiClient.instance.initDio(baseUrl: baseUrl, token: user.token!);
    context.rebuild(authProvider);
    context.redux(userMemoProvider).dispatch(RefreshMemoAction());
    context.pushReplacement('/');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    if (loginWithToken) {
      widgets.add(
        TextField(
          controller: _accessTokenController,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            labelText: context.intl.login_hint_access_token,
          ),
          onSubmitted: (value) {
            _login();
          },
        ),
      );
    } else {
      widgets.add(
        TextField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.intl.login_hint_username,
          ),
        ),
      );
      widgets.add(SizedBox(height: 16));
      widgets.add(
        TextField(
          controller: _passwordController,
          obscureText: obscurePassword,
          onSubmitted: (value) {
            _login();
          },
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            labelText: context.intl.login_hint_password,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).title_login)),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            DropdownButton(
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Text(context.intl.login_type_access_token),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text(context.intl.login_type_password),
                ),
              ],
              onChanged: _onLoginMethodChanged,
              value: loginWithToken,
            ),
            Spacer(),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                backgroundColor: Theme.of(context).colorScheme.primary,
                iconSize: 36,
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
              onPressed: _login,
              icon: Icon(Icons.login_outlined),
              label: Text(S.of(context).button_login),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.intl.login_tips),
            SizedBox(height: 16),
            TextField(
              controller: _baseUrlController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.intl.login_hint_host,
              ),
            ),
            SizedBox(height: 16),
            ...widgets,
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void _onLoginMethodChanged(bool? value) {
    setState(() {
      loginWithToken = value ?? false;
    });
  }
}
