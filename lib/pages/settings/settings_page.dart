import 'package:flutter/material.dart';
import 'package:fymemos/generated/l10n.dart';
import 'package:fymemos/pages/settings/settings_controller.dart';
import 'package:fymemos/ui/core/theme/color_mode.dart';
import 'package:fymemos/utils/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).title_settings)),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.contrast),
            title: Text(S.of(context).title_theme),
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
                  child: Text(S.of(context).theme_system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(S.of(context).theme_light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(S.of(context).theme_dark),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text(S.of(context).title_color_mode),
            trailing: DropdownButton<ColorMode>(
              value:
                  context.watch(settingsControllerProvider).settings.colorMode,
              onChanged: (ColorMode? value) {
                if (value == null) {
                  return;
                }
                context
                    .read(settingsControllerProvider)
                    .onChangeColorMode(context, value);
              },
              items:
                  context
                      .read(settingsControllerProvider)
                      .colorModes
                      .map(
                        (colorMode) => DropdownMenuItem<ColorMode>(
                          value: colorMode,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration:
                                    colorMode == ColorMode.system
                                        ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          gradient: SweepGradient(
                                            colors: [
                                              Colors.pink,
                                              Colors.red,
                                              Colors.yellow,
                                              Colors.orange,
                                              Colors.green,
                                              Colors.teal,
                                              Colors.blue,
                                            ],
                                          ),
                                        )
                                        : BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: colorMode.color,
                                        ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                colorMode == ColorMode.system
                                    ? context.intl.theme_system
                                    : colorMode.name,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text(S.of(context).privacy_policy),
            onTap: () async {
              launchUrlString("https://fymemos.isming.info/privacy");
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text(S.of(context).title_about),
            onTap: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              String appName = packageInfo.appName;
              String version = packageInfo.version;
              String buildNumber = packageInfo.buildNumber;
              showAboutDialog(
                context: context,
                applicationName: appName,
                applicationVersion: "$version($buildNumber)",
                applicationLegalese: '© 2025 明明同学',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text(S.of(context).button_logout),
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
