import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:training_log_app/utility/notifications.dart';
import '../widgets/app_drawer.dart';
import 'add_reminder_page.dart';
import 'edit_reminder_page.dart';
import 'package:training_log_app/utility/user_preferences.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<StatefulWidget> createState() => _RemindersPage();
}

class _RemindersPage extends State<RemindersPage> {
  String createStandardTimeFromMilitary(String timeString) {
    var now = DateTime.now().toString().split(' ')[0];
    var newTime = '$now $timeString:00.000000';
    var newDateTime = DateTime.parse(newTime);
    var newStringTime = DateFormat('h:mma').format(newDateTime);

    return newStringTime;
  }

  // reminders
  var allReminders = [];
  Map toggleValuesMap = {};

  @override
  void initState() {
    super.initState();

    // Get the reminders
    fetchAllReminders();
  }

  // Get all the reminders from the database.
  void fetchAllReminders() async {
    var result = await DatabaseHelper.instance.getReminders();

    for (var item in result) {
      setState(() {
        toggleValuesMap[item.id] = item.isOn;
      });
    }

    setState(() {
      allReminders = result;
    });
  }

  Widget buildNotesExpansionTile(BuildContext context, String notesText) {
    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 1,
        ),
        ExpansionTile(
          title: const Text(
            'Notes',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          leading: const Icon(Icons.note),
          children: [
            SizedBox(
              height: 100,
              child: Card(
                child: TextField(
                  controller: TextEditingController()..text = notesText,
                  expands: true,
                  maxLines: null,
                  readOnly: true,
                  showCursor: true,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Reminders'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: allReminders.map((element) {
                  var days = {};

                  if (element.monday == 1) {
                    days['MON'] = DateTime.monday;
                  }
                  if (element.tuesday == 1) {
                    days['TUE'] = DateTime.monday;
                  }
                  if (element.wednesday == 1) {
                    days['WED'] = DateTime.monday;
                  }
                  if (element.thursday == 1) {
                    days['THU'] = DateTime.monday;
                  }
                  if (element.friday == 1) {
                    days['FRI'] = DateTime.monday;
                  }
                  if (element.saturday == 1) {
                    days['SAT'] = DateTime.monday;
                  }
                  if (element.sunday == 1) {
                    days['SUN'] = DateTime.monday;
                  }

                  return FocusedMenuHolder(
                    menuWidth: MediaQuery.of(context).size.width * 0.5,
                    blurSize: 0,
                    openWithTap: false,
                    onPressed: () {},
                    menuItems: [
                      FocusedMenuItem(
                        title: const Text('EDIT'),
                        backgroundColor: Colors.blueAccent,
                        trailingIcon: const Icon(Icons.edit),
                        onPressed: () {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          // navigate
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                builder: (context) => EditRemindersPage(
                                    reminderId: element.id,
                                    timeString: element.time),
                              ))
                              .then((value) => setState(() {
                                    fetchAllReminders();
                                  }));
                        },
                      ),
                      FocusedMenuItem(
                        title: const Text('DELETE'),
                        backgroundColor: Colors.redAccent,
                        trailingIcon: const Icon(
                          Icons.delete_forever,
                        ),
                        onPressed: () async {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          await DatabaseHelper.instance
                              .removeReminder(element.id);
                          fetchAllReminders();

                          // cancel notification
                          debugPrint('deleted');
                          WorkoutNotification.cancelNotification(element.id);
                        },
                      ),
                    ],
                    child: Card(
                      child: ListTile(
                        title: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  createStandardTimeFromMilitary(element.time),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Transform.scale(
                                  scale: 1.20,
                                  child: Switch(
                                    value: toggleValuesMap[element.id] == 1
                                        ? true
                                        : false,
                                    onChanged: (bool? value) async {
                                      await DatabaseHelper.instance
                                          .updateReminderIsOn(element.id,
                                              (value == true ? 1 : 0));
                                      fetchAllReminders();

                                      if (value! == true) {
                                        var hour = int.parse(
                                            element.time.split(':')[0]);
                                        var minute = int.parse(
                                            element.time.split(':')[1]);
                                        if (days.length > 1) {
                                          debugPrint('created');
                                          WorkoutNotification
                                              .createWorkoutNotificationCron(
                                                  element.id,
                                                  days.keys.join(','),
                                                  hour,
                                                  minute);
                                        } else {
                                          WorkoutNotification
                                              .createWorkoutNotification(
                                                  element.id,
                                                  days[days.keys.first],
                                                  hour,
                                                  minute);
                                        }
                                      } else {
                                        debugPrint('cancelled');
                                        WorkoutNotification.cancelNotification(
                                            element.id);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(days.keys.join(', ')),
                                ],
                              ),
                            ),
                            // Only show notes if notes field not null in reminders table
                            if (element.notes != null)
                              buildNotesExpansionTile(context, element.notes),
                          ],
                        ),
                        onTap: () {},
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (UserPreferences.getVibrate() == true) {
            Vibrate.feedback(FeedbackType.heavy);
          }

          // navigate
          Navigator.of(context)
              .push(MaterialPageRoute(
                builder: (context) => const AddRemindersPage(),
              ))
              .then((value) => setState(() {
                    fetchAllReminders();
                  }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
