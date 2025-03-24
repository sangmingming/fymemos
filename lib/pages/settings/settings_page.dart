import 'package:flutter/material.dart';
import 'package:fymemos/pages/settings/setting_vm.dart';
import 'package:fymemos/pages/settings/settings_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:refena_flutter/refena_flutter.dart';
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
            leading: Icon(Icons.contrast),
            title: Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value:
                  context.watch(settingsControllerProvider).settings.themeMode,
              onChanged: (ThemeMode? value) {
                if (value == null) {
                  return;
                }
                context
                    .read(settingsControllerProvider)
                    .onChangeTheme(context, value);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
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
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              context.pushReplacement('/login');
            },
          ),
        ],
      ),
    );
  }
}
