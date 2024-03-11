import 'dart:collection';
import 'package:another_flushbar/flushbar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import 'package:training_log_app/models/routine_set_model.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/models/exercise_model.dart';
import 'package:training_log_app/pages/create_exercise_page.dart';

class EditRoutinePage extends StatefulWidget {
  final int routineId;
  final String routineName;

  const EditRoutinePage(
      {super.key, required this.routineId, required this.routineName});

  @override
  State<StatefulWidget> createState() => _EditRoutinePage();
}

class _EditRoutinePage extends State<EditRoutinePage> {
  // controllers
  TextEditingController routineNameController = TextEditingController();
  TextEditingController exerciseSelection = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightEditController = TextEditingController();
  TextEditingController repsEditController = TextEditingController();

  // holds exercises in routine
  Map chosenExercises = {};

  late List<RoutineSet> allSetData = <RoutineSet>[];

  HashMap nameFavoriteMap = HashMap();

  // holds exercises to display in search bar
  List<String> searchBarData = <String>[];

  // search bar radio button
  int selectedValue = 0;

  @override
  void initState() {
    super.initState();

    // Get list of exercises from exercises table.
    fetchExerciseData();
    fetchRoutineSets();
  }

  // Queries exercises table for all exercises and sets searchBarData.
  Future fetchExerciseData() async {
    List<Exercise> data;

    if (selectedValue == 0) {
      data = await DatabaseHelper.instance.getExercises();
    } else if (selectedValue == 1) {
      data = await DatabaseHelper.instance.getCustomExercises();
    } else {
      data = await DatabaseHelper.instance.getFavoriteExercises();
    }

    List allExercises = [];

    for (var element in data) {
      allExercises.add(element.name);
      if (!nameFavoriteMap.containsKey(element.name)) {
        setState(() {
          nameFavoriteMap[element.name] = element.isFavorite;
        });
      }
    }

    setState(() {
      searchBarData = List<String>.from(allExercises);
    });
  }

  Future<void> fetchRoutineSets() async {
    var query =
        await DatabaseHelper.instance.getSpecificRoutineSets(widget.routineId);

    Map exercisesMap = {};

    for (var item in query) {
      if (!exercisesMap.containsKey(item.name)) {
        exercisesMap[item.name] = 1;
      } else {
        exercisesMap[item.name]++;
      }
    }

    setState(() {
      allSetData = query;
      chosenExercises = exercisesMap;
    });
  }

  List<Widget> buildRoutineExercises(BuildContext context) {
    List<Widget> tiles = [];

    var exercises = chosenExercises.keys;

    for (var exercise in exercises) {
      tiles.add(FocusedMenuHolder(
        blurSize: 0,
        openWithTap: false,
        onPressed: () {},
        menuItems: [
          FocusedMenuItem(
              title: const Text('Delete'),
              trailingIcon: const Icon(Icons.delete_forever),
              onPressed: () async {
                if (UserPreferences.getVibrate() == true) {
                  Vibrate.feedback(FeedbackType.heavy);
                }
                // remove all sets for specific exercise
                await DatabaseHelper.instance
                    .removeSpecificRoutineSets(exercise);

                fetchRoutineSets();
              },
              backgroundColor: Colors.redAccent),
        ],
        child: Card(
          child: ExpansionTile(
            leading: badges.Badge(
              badgeContent: Text(chosenExercises[exercise].toString()),
              child: nameFavoriteMap[exercise] == 1
                  ? const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    )
                  : const Icon(Icons.fitness_center),
            ),
            title: Text(
              exercise,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            children: buildExerciseTiles(context, exercise),
          ),
        ),
      ));
    }
    return tiles;
  }

  List<Widget> buildExerciseTiles(BuildContext context, String exercise) {
    var tiles = <Widget>[];
    var setCount = 0;

    for (var i = 0; i < allSetData.length; i++) {
      var weight = allSetData[i].weight;
      var reps = allSetData[i].reps;

      if (allSetData[i].name == exercise) {
        setCount++;
        tiles.add(FocusedMenuHolder(
            blurSize: 0,
            openWithTap: false,
            onPressed: () {},
            menuItems: [
              FocusedMenuItem(
                title: const Text('Edit'),
                backgroundColor: Colors.blueAccent,
                trailingIcon: const Icon(Icons.edit),
                onPressed: () {
                  if (UserPreferences.getVibrate() == true) {
                    Vibrate.feedback(FeedbackType.heavy);
                  }

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Edit Set',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        height: 160,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextField(
                                controller: weightEditController,
                                decoration: InputDecoration(
                                  labelText: weight,
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextField(
                                controller: repsEditController,
                                decoration: InputDecoration(
                                  labelText: reps,
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            weightEditController.clear();
                            repsEditController.clear();
                          },
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            await DatabaseHelper.instance.updateRoutineSet(
                                allSetData[i].id!,
                                weightEditController.text,
                                repsEditController.text);

                            fetchRoutineSets();

                            // after adjusting stuff clear
                            weightEditController.clear();
                            repsEditController.clear();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              FocusedMenuItem(
                  title: const Text('Delete'),
                  trailingIcon: const Icon(Icons.delete_forever),
                  onPressed: () async {
                    if (UserPreferences.getVibrate() == true) {
                      Vibrate.feedback(FeedbackType.heavy);
                    }

                    await DatabaseHelper.instance
                        .removeSpecificRoutineSet(allSetData[i].id!);

                    setState(() {
                      chosenExercises[exercise]--;
                      if (chosenExercises[exercise] == 0) {
                        chosenExercises.remove(exercise);
                      }
                    });

                    fetchRoutineSets();
                  },
                  backgroundColor: Colors.redAccent),
            ],
            child: ListTile(
              title: Text(
                  "Set: ${setCount.toString()} | Weight: $weight | Reps: $reps"),
              onTap: () {},
            )));
      }
    }
    return tiles;
  }

  void showSetAddedSnackBar(BuildContext context) => Flushbar(
        backgroundColor: Colors.green.withOpacity(0.85),
        shouldIconPulse: false,
        message: 'Set added!',
        duration: const Duration(seconds: 1),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0),
      )..show(context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Routine'),
          centerTitle: false,
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    TextField(
                      controller: routineNameController
                        ..text = widget.routineName,
                      decoration: const InputDecoration(
                        labelText: 'Routine Name',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                              child: Autocomplete(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              } else {
                                return searchBarData.where((word) => word
                                    .toLowerCase()
                                    .contains(
                                        textEditingValue.text.toLowerCase()));
                              }
                            },
                            optionsViewBuilder: (context,
                                Function(String) onSelected, options) {
                              return Material(
                                elevation: 4,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);

                                    return ListTile(
                                      leading: FutureBuilder(
                                        future: DatabaseHelper.instance
                                            .isExerciseFavoriteName(
                                                option.toString()),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return snapshot.data == true
                                                ? const Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                  )
                                                : const Icon(
                                                    Icons.fitness_center);
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                      title: Text(option.toString()),
                                      onTap: () {
                                        onSelected(option.toString());
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemCount: options.length,
                                ),
                              );
                            },
                            onSelected: (String selectedString) {},
                            fieldViewBuilder: (BuildContext context, controller,
                                focusNode, onEditingComplete) {
                              exerciseSelection = controller;

                              return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: InputDecoration(
                                    labelText: 'Search exercise',
                                    prefixIcon: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      RadioListTile(
                                                        title:
                                                            const Text('All'),
                                                        value: 0,
                                                        groupValue:
                                                            selectedValue,
                                                        onChanged:
                                                            (value) async {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            selectedValue = 0;
                                                          });
                                                          await fetchExerciseData();
                                                        },
                                                      ),
                                                      RadioListTile(
                                                        title: const Text(
                                                            'Custom'),
                                                        value: 1,
                                                        groupValue:
                                                            selectedValue,
                                                        onChanged:
                                                            (value) async {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            selectedValue = 1;
                                                          });
                                                          await fetchExerciseData();
                                                        },
                                                      ),
                                                      RadioListTile(
                                                        title: const Text(
                                                            'Favorites'),
                                                        value: 2,
                                                        groupValue:
                                                            selectedValue,
                                                        onChanged:
                                                            (value) async {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            selectedValue = 2;
                                                          });
                                                          await fetchExerciseData();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.search),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: exerciseSelection.clear,
                                      icon: const Icon(Icons.clear),
                                    ),
                                  ));
                            },
                          )),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: TextField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: TextField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Row(
                      children: <Widget>[
                        Expanded(
                            child: Divider(
                          height: 100,
                          thickness: 5,
                        )),
                        Text(
                          'Exercises',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                            child: Divider(
                          height: 100,
                          thickness: 5,
                        )),
                      ],
                    ),
                    ...buildRoutineExercises(context),
                  ],
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

            // Query exercises table in db for exercise id.
            var currentExerciseId = await DatabaseHelper.instance
                .getSpecificExercise(exerciseSelection.text);

            // Open AlertDialog if the exercise doesn't exist in db.
            if (currentExerciseId.isEmpty &&
                exerciseSelection.text.isNotEmpty &&
                weightController.text.isNotEmpty &&
                repsController.text.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exercise does not exist in database.'),
                  content: const Text('Would you like to add it?'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        // navigate
                        await Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (context) => const CreateExercisePage(),
                        ))
                            .then((value) {
                          fetchExerciseData();
                          Navigator.pop(context);
                        });
                      },
                      child: const Text('ADD'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ],
                ),
              );
            } else if (exerciseSelection.text.isEmpty ||
                weightController.text.isEmpty ||
                repsController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Missing information'),
                  content:
                      const Text('Please enter information in all fields!'),
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
              // add set to sets table in db.

              // add exercise and set count
              if (!chosenExercises.containsKey(exerciseSelection.text)) {
                setState(() {
                  chosenExercises[exerciseSelection.text] = 1;
                });
              } else {
                setState(() {
                  chosenExercises[exerciseSelection.text]++;
                });
              }

              var exerciseId = (await DatabaseHelper.instance
                      .getSpecificExercise(exerciseSelection.text))[0]
                  .id;

              await DatabaseHelper.instance.addRoutineSet(RoutineSet(
                  routineId: widget.routineId,
                  exerciseId: exerciseId!,
                  name: exerciseSelection.text,
                  weight: weightController.text,
                  reps: repsController.text));

              fetchRoutineSets();

              if (!mounted) return;
              // show set added pop up
              showSetAddedSnackBar(context);
            }
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                if (UserPreferences.getVibrate() == true) {
                  Vibrate.feedback(FeedbackType.heavy);
                }

                if (routineNameController.text.isNotEmpty) {
                  Navigator.pop(context);

                  await DatabaseHelper.instance.updateSpecificRoutineName(
                      widget.routineId, routineNameController.text);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Missing information!'),
                      content: const Text('Please enter a routine name.'),
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
                }
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
