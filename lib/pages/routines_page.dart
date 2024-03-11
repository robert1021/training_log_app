import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/widgets/app_drawer.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import 'package:training_log_app/pages/add_routine_page.dart';
import 'package:training_log_app/pages/edit_routine_page.dart';
import 'package:training_log_app/models/routine_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<StatefulWidget> createState() => _RoutinesPage();
}

class _RoutinesPage extends State<RoutinesPage> {
  late List<Routine> routines = <Routine>[];

  @override
  void initState() {
    super.initState();

    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    var query = await DatabaseHelper.instance.getRoutines();

    setState(() {
      routines = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: routines.map((routine) {
                  return FocusedMenuHolder(
                    blurSize: 0,
                    openWithTap: false,
                    onPressed: () {},
                    menuItems: [
                      FocusedMenuItem(
                        title: const Text('EDIT'),
                        backgroundColor: Colors.blueAccent,
                        trailingIcon: const Icon(Icons.edit),
                        onPressed: () async {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          // navigate
                          await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => EditRoutinePage(
                                routineId: routine.id!,
                                routineName: routine.name),
                          ))
                              .then((value) {
                            fetchRoutines();
                          });
                        },
                      ),
                      FocusedMenuItem(
                        title: const Text('DELETE'),
                        trailingIcon: const Icon(Icons.delete_forever),
                        onPressed: () async {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          // Delete the routine from the routines table.
                          await DatabaseHelper.instance
                              .removeRoutine(routine.id!);

                          fetchRoutines();
                        },
                        backgroundColor: Colors.redAccent,
                      ),
                    ],
                    child: Card(
                      child: ListTile(
                        onTap: () {},
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Name:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      routine.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],

                              ),
                            ),

                            const Divider(
                              height: 1,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Difficulty:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  RatingBar.builder(
                                    initialRating: routine.difficulty.toDouble(),
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 3,
                                    itemPadding:
                                        const EdgeInsets.symmetric(horizontal: 3.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) async {
                                      await DatabaseHelper.instance.updateSpecificRoutineDifficulty(routine.id!, rating.toInt());
                                    },

                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
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
        onPressed: () async {
          if (UserPreferences.getVibrate() == true) {
            Vibrate.feedback(FeedbackType.heavy);
          }

          // navigate
          await Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => const AddRoutinePage(),
          ))
              .then((value) {
            fetchRoutines();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
