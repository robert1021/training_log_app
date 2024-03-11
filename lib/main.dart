import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:training_log_app/pages/workout.dart';
import 'package:training_log_app/provider/navigation_provider.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // create db and tables
  DatabaseHelper.instance;
  // Initialize notifications - Needs to be done before starting app ***
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'key1',
        channelName: 'Workout',
        channelDescription: 'Workout Reminder',
        defaultColor: Colors.white,
        ledColor: Colors.green,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        locked: true,
      )
    ],
  );
  // load preferences
  await UserPreferences.init();
  if (UserPreferences.getScreenOn() == null) {
    await UserPreferences.setScreenOn(false);
  }
  var timeOutToggle = UserPreferences.getScreenOn()!;
  // start app
  runApp(MyApp(screenTimeOutToggle: timeOutToggle));
}

class MyApp extends StatelessWidget {
  final bool screenTimeOutToggle;

  const MyApp({super.key, required this.screenTimeOutToggle});

  @override
  Widget build(BuildContext context) {
    if (screenTimeOutToggle == true) {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }

    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ],
        child: MaterialApp(
          home: WorkoutPage(dateToLoad: DateTime.now()),
          theme: theme,
          darkTheme: darkTheme,
          
        ),
      ),
    );
  }
}
