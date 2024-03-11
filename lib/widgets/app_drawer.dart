
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_log_app/models/navigation_model.dart';
import 'package:training_log_app/provider/navigation_provider.dart';
import '../pages/calendar_page.dart';
import '../pages/exercises_page.dart';
import '../pages/one_rep_max_page.dart';
import '../pages/reminders_page.dart';
import '../pages/stopwatch_page.dart';
import '../pages/settings_page.dart';
import '../pages/workout.dart';
import 'package:training_log_app/pages/routines_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Logic for the workout menu item
  void workoutOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => WorkoutPage(dateToLoad: DateTime.now()),
    ));
  }

  // Logic for the exercises menu item
  void exercisesOnTapFunc(context) {
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ExercisePage(),
    ));
  }

  // Logic for the calendar menu item
  void calendarOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const CalendarPage(),
    ));
  }

  void routinesOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const RoutinesPage(),
    ));
  }

  // Logic for the one rep max menu item
  void oneRepMaxOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const OneRepMaxPage(),
    ));
  }

  // Logic for the stopwatch timer menu item
  void stopwatchTimerOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const StopWatchPage(),
    ));
  }

  // Logic for the reminders menu item
  void remindersOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const RemindersPage(),
    ));
  }

  // Logic for the account settings menu item
  void accountSettingsOnTapFunc(context) {
    // close navigation drawer
    Navigator.pop(context);

    // navigate
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ));
  }


  static void selectItem(BuildContext context, NavigationItem item) {
    final provider = Provider.of<NavigationProvider>(context, listen: false);
    provider.setNavigationItem(item);
  }

  Widget buildHeader(BuildContext context,
      {required NavigationItem item,
      required userImage,
      required userName,
      required userEmail}) {
      const String defaultName = '';
      const String defaultEmail = '';

    return Material(
      color: Colors.blue,
      child: InkWell(
        onTap: () {
          selectItem(context, item);

          // close navigation drawer
          Navigator.pop(context);

          // navigate
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WorkoutPage(dateToLoad: DateTime.now()),
          ));
        },
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              if (userImage == null)
                Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      child: Transform.scale(
                        scale: 1.5,
                        child: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const Text(''),
                  ],
                ),
              if (userImage != null)
                Column(
                  children: [
                    CircleAvatar(
                        radius: 52, backgroundImage: NetworkImage(userImage)),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      userName ?? defaultName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      userEmail ?? defaultEmail,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(BuildContext context,
      {required NavigationItem item,
      required String text,
      required IconData icon,
      required Function onTapFunc}) {
    final provider = Provider.of<NavigationProvider>(context);
    final currentItem = provider.navigationItem;
    final isSelected = item == currentItem;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.grey.withOpacity(0.25),
      leading: Icon(icon),
      title: Text(
        text,
        style: const TextStyle(fontSize: 20),
      ),
      onTap: () {
        selectItem(context, item);
        onTapFunc(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 36,
          ),
          const Center(
            child: Text(
              "Training Log",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const Divider(
            height: 25,
            thickness: 5,
          ),

          buildMenuItem(context,
              item: NavigationItem.workout,
              text: 'Workout',
              icon: Icons.work,
              onTapFunc: workoutOnTapFunc),
          buildMenuItem(context,
              item: NavigationItem.exercises,
              text: 'Exercises',
              icon: Icons.fitness_center,
              onTapFunc: exercisesOnTapFunc),
          buildMenuItem(context,
              item: NavigationItem.calendar,
              text: 'Calendar',
              icon: Icons.calendar_month,
              onTapFunc: calendarOnTapFunc),
          buildMenuItem(
            context,
            item: NavigationItem.routines,
            text: 'Routines',
            icon: Icons.checklist,
            onTapFunc: routinesOnTapFunc,
          ),
          buildMenuItem(context,
              item: NavigationItem.oneRepMax,
              text: 'One Rep Max',
              icon: Icons.calculate,
              onTapFunc: oneRepMaxOnTapFunc),
          buildMenuItem(context,
              item: NavigationItem.stopwatchTimer,
              text: 'Stopwatch Timer',
              icon: Icons.timer,
              onTapFunc: stopwatchTimerOnTapFunc),
          buildMenuItem(context,
              item: NavigationItem.reminders,
              text: 'Reminders',
              icon: Icons.schedule,
              onTapFunc: remindersOnTapFunc),
          const Divider(
            height: 25,
            thickness: 5,
          ),
          buildMenuItem(context,
              item: NavigationItem.accountSettings,
              text: 'Account Settings',
              icon: Icons.settings,
              onTapFunc: accountSettingsOnTapFunc),

        ],
      ),
    );
  }
}
