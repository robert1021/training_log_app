import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/models/reminder_model.dart';
import 'package:training_log_app/utility/notifications.dart';
import 'package:training_log_app/utility/user_preferences.dart';

class AddRemindersPage extends StatefulWidget {
  const AddRemindersPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddRemindersPage();
}

class _AddRemindersPage extends State<AddRemindersPage> {
  // controllers
  final notesController = TextEditingController();

  // time
  late DateTime _dateTime;
  // days
  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;
  bool sunday = false;
  bool everyday = false;

  // Notes
  bool notesAdded = false;

  @override
  void initState() {
    super.initState();
    // WorkoutNotification.cancelAllNotifications();
  }

  void checkAllDays() {
    setState(() {
      monday = true;
      tuesday = true;
      wednesday = true;
      thursday = true;
      friday = true;
      saturday = true;
      sunday = true;
      everyday = true;
    });
  }

  void unselectAllDays() {
    setState(() {
      monday = false;
      tuesday = false;
      wednesday = false;
      thursday = false;
      friday = false;
      saturday = false;
      sunday = false;
      everyday = false;
    });
  }

  Widget buildNotesSection(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        child: TextField(
          controller: notesController,
          expands: true,
          maxLines: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: TimePickerSpinner(
                        is24HourMode: false,
                        normalTextStyle:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                        highlightedTextStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        spacing: 50,
                        itemHeight: 80,
                        isForce2Digits: true,
                        onTimeChange: (time) {
                          setState(() {
                            _dateTime = time;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        children: [
                          const Divider(
                            height: 1,
                            thickness: 1,
                          ),
                          ListTile(
                            title: Text(
                              !notesAdded ? 'Add Notes' : 'Remove Notes',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              if (UserPreferences.getVibrate() == true) {
                                Vibrate.feedback(FeedbackType.heavy);
                              }

                              setState(() {
                                notesAdded = !notesAdded;

                                // clear the notes controller
                                if (notesAdded == false) {
                                  notesController.clear();
                                }
                              });
                            },
                            leading: const Icon(Icons.note),
                            trailing: !notesAdded
                                ? const Icon(Icons.add)
                                : const Icon(Icons.delete),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                    if (notesAdded) buildNotesSection(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Everyday',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Transform.scale(
                          scale: 1.20,
                          child: Checkbox(
                            value: everyday,
                            onChanged: (value) {
                              everyday = value!;
                              if (value) {
                                checkAllDays();
                              } else {
                                unselectAllDays();
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
                    CheckboxListTile(
                      title: const Text('Monday'),
                      value: monday,
                      onChanged: (bool? value) async {
                        setState(() {
                          monday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    CheckboxListTile(
                      title: const Text('Tuesday'),
                      value: tuesday,
                      onChanged: (bool? value) async {
                        setState(() {
                          tuesday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    CheckboxListTile(
                      title: const Text('Wednesday'),
                      value: wednesday,
                      onChanged: (bool? value) async {
                        setState(() {
                          wednesday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    CheckboxListTile(
                      title: const Text('Thursday'),
                      value: thursday,
                      onChanged: (bool? value) async {
                        setState(() {
                          thursday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    CheckboxListTile(
                      title: const Text('Friday'),
                      value: friday,
                      onChanged: (bool? value) async {
                        setState(() {
                          friday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    CheckboxListTile(
                      title: const Text('Saturday'),
                      value: saturday,
                      onChanged: (bool? value) async {
                        setState(() {
                          saturday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    CheckboxListTile(
                      title: const Text('Sunday'),
                      value: sunday,
                      onChanged: (bool? value) async {
                        setState(() {
                          sunday = value!;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (UserPreferences.getVibrate() == true) {
                Vibrate.feedback(FeedbackType.heavy);
              }

              if (!monday &&
                  !tuesday &&
                  !wednesday &&
                  !thursday &&
                  !friday &&
                  !friday &&
                  !sunday) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Missing information'),
                    content: const Text('Please select at least one day!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                await DatabaseHelper.instance.addReminder(Reminder(
                    isOn: 1,
                    time: _dateTime.toString().split(' ')[1].substring(0, 5),
                    monday: monday == true ? 1 : 0,
                    tuesday: tuesday == true ? 1 : 0,
                    wednesday: wednesday == true ? 1 : 0,
                    thursday: thursday == true ? 1 : 0,
                    friday: friday == true ? 1 : 0,
                    saturday: saturday == true ? 1 : 0,
                    sunday: sunday == true ? 1 : 0,
                    notes: (notesController.text.isEmpty ||
                            notesController.text == '')
                        ? null
                        : notesController.text));
                if (!mounted) return;
                // Go back to previous screen
                Navigator.pop(context);

                var data = await DatabaseHelper.instance.getReminders();
                var nextId = data.last.id!;
                var hour = int.parse(
                    _dateTime.toString().split(' ')[1].substring(0, 2));
                var minute =
                    int.parse(_dateTime.toString().split(' ')[1].split(':')[1]);

                var days = {};

                if (monday) {
                  days['MON'] = DateTime.monday;
                }
                if (tuesday) {
                  days['TUE'] = DateTime.tuesday;
                }
                if (wednesday) {
                  days['WED'] = DateTime.wednesday;
                }
                if (thursday) {
                  days['THU'] = DateTime.thursday;
                }
                if (friday) {
                  days['FRI'] = DateTime.friday;
                }
                if (saturday) {
                  days['SAT'] = DateTime.saturday;
                }
                if (sunday) {
                  days['SUN'] = DateTime.sunday;
                }

                if (days.length > 1) {
                  WorkoutNotification.createWorkoutNotificationCron(
                      nextId, days.keys.join(','), hour, minute);
                } else {
                  WorkoutNotification.createWorkoutNotification(
                      nextId, days[days.keys.first], hour, minute);
                }
              }
            },
            child: const Text(
              'Add Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
