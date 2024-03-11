import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:training_log_app/utility/user_preferences.dart';

import '../widgets/app_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  bool darkModeToggle = false;
  bool keepScreenOnChecked = false;
  bool vibrateChecked = false;

  @override
  void initState() {
    super.initState();

    // dark mode
    if (UserPreferences.getDarkMode() == null) {
      UserPreferences.setDarkModeToggle(darkModeToggle);
    } else {
      setState(() {
        darkModeToggle = UserPreferences.getDarkMode()!;
      });
    }

    // keep screen on
    if (UserPreferences.getScreenOn() == null) {
      UserPreferences.setScreenOn(keepScreenOnChecked);
    } else {
      setState(() {
        keepScreenOnChecked = UserPreferences.getScreenOn()!;
      });
    }

    // vibrate
    if (UserPreferences.getVibrate() == null) {
      UserPreferences.setVibrate(vibrateChecked);
    } else {
      setState(() {
        vibrateChecked = UserPreferences.getVibrate()!;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Account Settings'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Card(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            'General',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          value: darkModeToggle,
                          onChanged: (bool? value) async {
                            // Enable / disable dark mode with toggle
                            if (value == false) {
                              AdaptiveTheme.of(context).setLight();
                            } else {
                              AdaptiveTheme.of(context).setDark();
                            }

                            await UserPreferences.setDarkModeToggle(value!);

                            setState(() {
                              darkModeToggle = value;
                            });
                          },
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        CheckboxListTile(
                          title: const Text('Vibration'),
                          value: vibrateChecked,
                          onChanged: (bool? value) async {
                            await UserPreferences.setVibrate(
                                value!);

                            setState(() {
                              vibrateChecked = value;
                            });
                          },
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        CheckboxListTile(
                          title: const Text('Keep Screen On'),
                          value: keepScreenOnChecked,
                          onChanged: (bool? value) async {
                            if (value == true) {
                              await Wakelock.enable();
                            } else {
                              await Wakelock.disable();
                            }

                            await UserPreferences.setScreenOn(value!);

                            setState(() {
                              keepScreenOnChecked = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
