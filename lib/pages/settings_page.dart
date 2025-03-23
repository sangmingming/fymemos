import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'FyMemos',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 明明同学',
              );
            },
          ),
        ],
      ),
    );
  }
}
