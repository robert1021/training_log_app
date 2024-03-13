import 'dart:collection';
import 'package:badges/badges.dart' as badges;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:training_log_app/models/workout_model.dart';
import 'package:training_log_app/pages/single_exercise_page.dart';
import 'package:training_log_app/db/database_helper.dart';
import '../models/set_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';
import 'package:training_log_app/utility/user_preferences.dart';
import '../widgets/app_drawer.dart';
import 'package:training_log_app/pages/create_exercise_page.dart';
import 'package:training_log_app/models/exercise_model.dart';
import 'package:training_log_app/models/routine_model.dart';
import 'package:training_log_app/widgets/star_icons.dart';
import 'package:training_log_app/widgets/custom_snackbars.dart';
import 'package:training_log_app/pages/workout_notes_page.dart';
import 'package:training_log_app/pages/add_routine_page.dart';

class WorkoutPage extends StatefulWidget {
  final DateTime dateToLoad;

  const WorkoutPage({super.key, required this.dateToLoad});

  @override
  State<StatefulWidget> createState() => _WorkoutPage();
}

class _WorkoutPage extends State<WorkoutPage> {
  DateTime date = DateTime.now();

  // if false will show the create workout button
  var isWorkoutExisting = false;
  var isLoading = true;

  // workout id used for the db
  late int workoutId;

  //
  HashMap nameFavoriteMap = HashMap();

  // holds exercises to display in search bar
  List<String> searchBarData = <String>[];

  // holds all the set data
  late Map sets = {};

  Iterable<dynamic> chosenExercises = [];
  var allSetData = [];
  var chosenExercisesSets = {};
  var randomColors = HashMap();

  // dropdown
  var dropDownSelected = 'Volume Pie';
  var dropDownItems = ['Volume Pie', 'Volume Bar'];

  // controllers
  TextEditingController exerciseSelection = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightEditController = TextEditingController();
  TextEditingController repsEditController = TextEditingController();

  // search bar radio button
  int selectedValue = 0;

  // routines
  late List<Routine> routines = <Routine>[];

  //
  @override
  void initState() {
    super.initState();

    date = widget.dateToLoad;

    // Get list of exercises from exercises table.
    fetchExerciseData();

    // check if today's date (default selection) already exists in workouts table.
    fetchWorkoutExisting(date.toString().split(' ')[0]);
    // fetchWorkoutExisting(date.toString().split(' ')[0]);

    fetchRoutines();

    exerciseSelection.addListener(() => setState(() {}));
    weightController.addListener(() => setState(() {}));
    repsController.addListener(() => setState(() {}));
    weightEditController.addListener(() => setState(() {}));
    repsEditController.addListener(() => setState(() {}));

    // DatabaseHelper.instance.deleteDatabase();
  }

  // Queries workouts table to see if a workout exists for specified [date].
  // Sets isWorkoutExisting with true or false.
  Future fetchWorkoutExisting(String date) async {
    late List<WorkoutData> workoutIdResult;
    late List specificWorkoutSets;
    Map exerciseIdMap = {};
    Map exerciseSetMap = {};

    var result = await DatabaseHelper.instance.isWorkoutExisting(date);

    if (result) {
      workoutIdResult = await DatabaseHelper.instance.getWorkout(date);
      specificWorkoutSets = await DatabaseHelper.instance
          .getWorkoutsAllSpecificData(workoutIdResult.elementAt(0).id!);

      // Get exercises added to workout.
      for (var item in specificWorkoutSets) {
        if (!exerciseIdMap.containsKey(item['name'])) {
          exerciseIdMap[item['name']] = item['exerciseId'];
        }
      }

      for (var item in exerciseIdMap.keys) {
        var sets = await DatabaseHelper.instance
            .getWorkoutsAllSpecificExerciseWorkoutData(
                item, workoutIdResult.elementAt(0).id!);
        exerciseSetMap[item] = sets.length;
      }
    }

    setState(() {
      isWorkoutExisting = result;
      isLoading = false;
      if (result) {
        workoutId = workoutIdResult.elementAt(0).id!;
        chosenExercises = exerciseIdMap.keys;
        chosenExercisesSets = exerciseSetMap;
        allSetData = specificWorkoutSets;
      }
    });
  }

  // Queries exercises table for all exercises and sets searchBarData.
  Future<void> fetchExerciseData() async {
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

  Future<void> fetchRoutines() async {
    var query = await DatabaseHelper.instance.getRoutines();

    setState(() {
      routines = query;
    });
  }

  void addSet(int currentExerciseId) async {
    await DatabaseHelper.instance.addSet(SetData(
      workoutId: workoutId,
      exerciseId: currentExerciseId,
      weight: weightController.text,
      reps: repsController.text,
      timestamp: DateTime.now().toString(),
    ));

    var specificWorkoutSets =
        await DatabaseHelper.instance.getWorkoutsAllSpecificData(workoutId);

    setState(() {
      allSetData = specificWorkoutSets;
    });
  }

  List<Widget> buildExerciseTiles(BuildContext context, String exercise) {
    var tiles = <Widget>[];
    var setCount = 0;

    for (var item in allSetData) {
      var setId = item['setId'];
      var weight = item['weight'];
      var reps = item['reps'];

      if (item['name'] == exercise) {
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

                            Map exerciseIdMap = {};
                            await DatabaseHelper.instance.updateSet(
                                setId,
                                weightEditController.text.isEmpty
                                    ? weight
                                    : weightEditController.text,
                                repsEditController.text.isEmpty
                                    ? reps
                                    : repsEditController.text,
                                DateTime.now().toString());

                            var specificWorkoutSets = await DatabaseHelper
                                .instance
                                .getWorkoutsAllSpecificData(workoutId);

                            // Get exercises added to workout.
                            for (var item in specificWorkoutSets) {
                              if (!exerciseIdMap.containsKey(item['name'])) {
                                exerciseIdMap[item['name']] =
                                    item['exerciseId'];
                              }
                            }

                            setState(() {
                              allSetData = specificWorkoutSets;
                              chosenExercises = exerciseIdMap.keys;
                            });

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
                    Map exerciseIdMap = {};
                    await DatabaseHelper.instance.removeSet(setId);

                    var specificWorkoutSets = await DatabaseHelper.instance
                        .getWorkoutsAllSpecificData(workoutId);

                    // Get exercises added to workout.
                    for (var item in specificWorkoutSets) {
                      if (!exerciseIdMap.containsKey(item['name'])) {
                        exerciseIdMap[item['name']] = item['exerciseId'];
                      }
                    }

                    setState(() {
                      allSetData = specificWorkoutSets;
                      chosenExercises = exerciseIdMap.keys;
                      chosenExercisesSets[item['name']] =
                          chosenExercisesSets[item['name']] - 1;
                    });
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

  // Pie chart of volume of each exercise
  Widget buildVolumePieChart(
      BuildContext context, int totalReps, int totalSets, double totalVolume) {
    // holds color map
    // var randomColors = HashMap();

    // build map to hold all the data
    Map data = {
      for (var item in chosenExercises)
        '$item': {
          'reps': 0,
          'sets': 0,
          'volume': 0.0,
          'percent': 0.0,
          'color': ''
        }
    };

    // add all the data
    for (var item in allSetData) {
      // check if null
      if (data[item['name']] != null) {
        // reps
        data[item['name']]['reps'] += int.parse(item['reps']);
        // sets
        data[item['name']]['sets']++;
        // volume
        data[item['name']]['volume'] +=
            double.parse(item['weight']) * double.parse(item['reps']);
      }
    }

    for (var key in data.keys) {
      // calculate percent
      data[key]['percent'] = (data[key]['volume'] / totalVolume) * 100;
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: chosenExercises.map((exercise) {
                return PieChartSectionData(
                  radius: 50,
                  color: randomColors[exercise],
                  value: data[exercise]['percent'],
                  title: '${data[exercise]['percent'].toStringAsFixed(2)}%',
                );
              }).toList(),
            ),
          ),
        ),
        ExpansionTile(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(
                  'Legend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                labelPadding: EdgeInsets.all(4),
                avatar: CircleAvatar(
                  child: Icon(Icons.legend_toggle),
                ),
              ),
            ],
          ),
          children: chosenExercises.map((exercise) {
            return ListTile(
              title: Text(exercise),
              tileColor: randomColors[exercise],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Pie chart of volume of each exercise
  Widget buildVolumeBarChart(
      BuildContext context, int totalReps, int totalSets, double totalVolume) {
    // holds color map
    // var randomColors = HashMap();

    // build map to hold all the data
    Map data = {
      for (var item in chosenExercises)
        '$item': {
          'reps': 0,
          'sets': 0,
          'volume': 0.0,
          'percent': 0.0,
          'color': ''
        }
    };

    // add all the data
    for (var item in allSetData) {
      // check if null
      if (data[item['name']] != null) {
        // reps
        data[item['name']]['reps'] += int.parse(item['reps']);
        // sets
        data[item['name']]['sets']++;
        // volume
        data[item['name']]['volume'] +=
            double.parse(item['weight']) * double.parse(item['reps']);
      }
    }

    // holds the max X for the chart
    var maxY = 0.0;

    for (var item in data.keys) {
      if (data[item]['volume'] > maxY) {
        maxY = data[item]['volume'];
      }
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: maxY,
              minY: 0,
              groupsSpace: 12,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: false,
              ),
              barGroups: chosenExercises.map((exercise) {
                return BarChartGroupData(
                  x: chosenExercises.toList().indexOf(exercise),
                  barRods: [
                    BarChartRodData(
                      toY: data[exercise]['volume'],
                      color: randomColors[exercise],
                      width: chosenExercises.length <= 14 ? 15 : 10,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        ExpansionTile(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(
                  'Legend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                labelPadding: EdgeInsets.all(4),
                avatar: CircleAvatar(
                  child: Icon(Icons.legend_toggle),
                ),
              ),
            ],
          ),
          children: chosenExercises.map((exercise) {
            return ListTile(
              title: Text(exercise),
              tileColor: randomColors[exercise],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildStatsTab(BuildContext context) {
    var uniqueExercises = chosenExercises.length;
    var totalSets = allSetData.length;
    var totalReps = 0;
    var totalVolume = 0.0;

    // Get total reps and volume.
    for (var item in allSetData) {
      totalReps += int.parse(item['reps']);
      totalVolume += double.parse(item['weight']) * double.parse(item['reps']);
    }

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButton(
              isExpanded: true,
              value: dropDownSelected,
              items: dropDownItems
                  .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 20),
                      )))
                  .toList(),
              onChanged: (item) => setState(
                () => dropDownSelected = item.toString(),
              ),
            ),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(10), children: [
              if (dropDownSelected == 'Volume Pie')
                buildVolumePieChart(context, totalReps, totalSets, totalVolume),
              if (dropDownSelected == 'Volume Bar')
                buildVolumeBarChart(context, totalReps, totalSets, totalVolume),
              DataTable(
                headingRowHeight: 0,
                columns: const [
                  DataColumn(
                    label: Text(''),
                  ),
                  DataColumn(
                    label: Text(''),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      const DataCell(Text(
                        'Unique Exercises',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                      DataCell(Text(
                        '$uniqueExercises',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ))
                    ],
                    onLongPress: () {},
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text(
                        'Total Sets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                      DataCell(Text(
                        '$totalSets',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ))
                    ],
                    onLongPress: () {},
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text(
                        'Total Reps',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                      DataCell(Text(
                        '$totalReps',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ))
                    ],
                    onLongPress: () {},
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text(
                        'Total Volume',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                      DataCell(Text(
                        '$totalVolume',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ))
                    ],
                    onLongPress: () {},
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }

  Widget buildRoutineTiles(BuildContext context) {
    List<Widget> routineTiles = [];

    for (var routine in routines) {
      routineTiles.add(Column(
        children: [
          ListTile(
            title: Text(
              routine.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: StarIcons(stars: routine.difficulty),
            onTap: () async {
              var routineSets = await DatabaseHelper.instance
                  .getSpecificRoutineSets(routine.id!);

              // insert all sets in sets table of database
              for (var routineSet in routineSets) {
                await DatabaseHelper.instance.addSet(SetData(
                    workoutId: workoutId,
                    exerciseId: routineSet.exerciseId,
                    weight: routineSet.weight,
                    reps: routineSet.reps,
                    timestamp: DateTime.now().toString()));
              }

              fetchWorkoutExisting(date.toString().split(' ')[0]);

              if (!mounted) return;
              Navigator.pop(context);

              ShowCustomSnackBars.showRoutineAddedSnackBar(context);
            },
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ],
      ));
    }
    return SizedBox(
      height: 150,
      width: double.maxFinite,
      child: Scrollbar(
        child: ListView(
          children: routineTiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Workout'),
            centerTitle: false,
            actions: [
              if (isWorkoutExisting)
                IconButton(
                  onPressed: () async {
                    if (UserPreferences.getVibrate() == true) {
                      Vibrate.feedback(FeedbackType.heavy);
                    }
                    // navigate
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          WorkoutNotesPage(workoutId: workoutId),
                    ));
                  },
                  icon: const Icon(Icons.note),
                ),
              if (isWorkoutExisting)
                IconButton(
                  onPressed: () {
                    if (UserPreferences.getVibrate() == true) {
                      Vibrate.feedback(FeedbackType.heavy);
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select routine to add'),
                        content: SizedBox(
                          height: 160,
                          child: routines.isNotEmpty
                              ? Column(
                                  children: [
                                    buildRoutineTiles(context),
                                  ],
                                )
                              : Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (UserPreferences.getVibrate() ==
                                          true) {
                                        Vibrate.feedback(FeedbackType.heavy);
                                      }

                                      // navigate
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const AddRoutinePage(),
                                      ))
                                          .then((value) {
                                        Navigator.pop(context);
                                        fetchRoutines();
                                      });
                                    },
                                    child: const Text(
                                      'Add Routine',
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
                  },
                  icon: const Icon(Icons.checklist),
                ),
              if (isWorkoutExisting)
                IconButton(
                  onPressed: () {
                    if (UserPreferences.getVibrate() == true) {
                      Vibrate.feedback(FeedbackType.heavy);
                    }
                    if (isWorkoutExisting) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Workout'),
                          content: const Text(
                              'Clicking OK will delete this workout from the Database forever!'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Delete workout from database
                                DatabaseHelper.instance
                                    .removeWorkout(workoutId);

                                setState(() {
                                  isWorkoutExisting = false;
                                });

                                Navigator.pop(context);
                                debugPrint('OK pressed');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'LOG'),
                Tab(text: 'STATS'),
              ],
            ),
          ),
          drawer: const AppDrawer(),
          body: TabBarView(children: [
            Center(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2200),
                          );

                          // if CANCEL => null
                          if (newDate == null) return;

                          // if OK => DateTime
                          setState(() {
                            date = newDate;
                            isLoading = true;
                          });

                          await Future.delayed(
                              const Duration(milliseconds: 750));

                          fetchWorkoutExisting(date.toString().split(' ')[0]);
                          // clear weight and reps
                          weightController.clear();
                          repsController.clear();
                        },
                        icon: const Icon(Icons.calendar_month),
                      ),
                      Text(date.toString().split(' ')[0]),
                    ],
                  ),
                  const Divider(),
                  // Show create workout button
                  if (isLoading)
                    const SpinKitCircle(
                      size: 140,
                      color: Colors.blue,
                    ),

                  if (isWorkoutExisting && !isLoading)
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
                                                    color: Colors.amber,
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
                  if (isWorkoutExisting && !isLoading)
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: TextField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight',
                          border: const OutlineInputBorder(),
                          suffixIcon: weightController.text.isEmpty
                              ? Container(
                                  width: 0,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => weightController.clear(),
                                ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  if (isWorkoutExisting && !isLoading)
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 5),
                      child: TextField(
                        controller: repsController,
                        decoration: InputDecoration(
                          labelText: 'Reps',
                          border: const OutlineInputBorder(),
                          suffixIcon: repsController.text.isEmpty
                              ? Container(
                                  width: 0,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => repsController.clear(),
                                ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  if (isWorkoutExisting && !isLoading)
                    const Row(
                      children: <Widget>[
                        Expanded(
                            child: Divider(
                          height: 100,
                          thickness: 5,
                        )),
                        Text(
                          'Sets completed',
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
                  if (isWorkoutExisting && !isLoading)
                    Column(
                      children: chosenExercises.map((item) {
                        while (true) {
                          var newColor = Colors.primaries[
                              Random().nextInt(Colors.primaries.length)];
                          if (!randomColors.containsKey(item)) {
                            if (!randomColors.values.contains(newColor)) {
                              randomColors[item] = newColor;
                              break;
                            }
                          } else {
                            break;
                          }
                        }

                        return FocusedMenuHolder(
                          blurSize: 0,
                          openWithTap: false,
                          onPressed: () {},
                          menuItems: [
                            FocusedMenuItem(
                              title: const Text('Info'),
                              backgroundColor: Colors.blueAccent,
                              onPressed: () {
                                if (UserPreferences.getVibrate() == true) {
                                  Vibrate.feedback(FeedbackType.heavy);
                                }
                                // navigate
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      SingleExerciseTabs(exercise: item),
                                ));
                              },
                              trailingIcon: const Icon(Icons.info),
                            ),
                            FocusedMenuItem(
                                title: const Text('Delete'),
                                trailingIcon: const Icon(Icons.delete_forever),
                                onPressed: () async {
                                  if (UserPreferences.getVibrate() == true) {
                                    Vibrate.feedback(FeedbackType.heavy);
                                  }

                                  Map exerciseIdMap = {};

                                  var specificWorkoutSets = await DatabaseHelper
                                      .instance
                                      .getWorkoutsAllSpecificData(workoutId);

                                  for (var element in specificWorkoutSets) {
                                    if (element['name'] == item.toString()) {
                                      await DatabaseHelper.instance
                                          .removeSet(element['setId']);
                                    }
                                  }

                                  var newSpecificWorkoutSets =
                                      await DatabaseHelper.instance
                                          .getWorkoutsAllSpecificData(
                                              workoutId);

                                  // Get exercises added to workout.
                                  for (var element in newSpecificWorkoutSets) {
                                    if (!exerciseIdMap
                                        .containsKey(element['name'])) {
                                      exerciseIdMap[element['name']] =
                                          element['exerciseId'];
                                    }
                                  }

                                  setState(() {
                                    allSetData = newSpecificWorkoutSets;
                                    chosenExercises = exerciseIdMap.keys;
                                    // remove exercise color pair so the color can be used again
                                    randomColors.remove(item);
                                  });
                                },
                                backgroundColor: Colors.redAccent),
                          ],
                          child: Card(
                            child: ExpansionTile(
                              // leading: const Icon(Icons.fitness_center),
                              leading: badges.Badge(
                                badgeAnimation: const badges.BadgeAnimation.scale(),
                                badgeContent:
                                    Text(chosenExercisesSets[item].toString()),
                                child: nameFavoriteMap[item] == 1
                                    ? const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      )
                                    : const Icon(Icons.fitness_center),
                              ),
                              title: Text(
                                item,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              children: buildExerciseTiles(context, item),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            if (isWorkoutExisting && !isLoading) buildStatsTab(context),
            if (!isWorkoutExisting || isLoading) const Text(''),
          ]),
          floatingActionButton: Visibility(
            visible: isWorkoutExisting,
            child: FloatingActionButton(
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
                  addSet(currentExerciseId[0].id ?? 0);

                  if (!mounted) return;

                  // show set added pop up
                  ShowCustomSnackBars.showSetAddedSnackBar(context);
                }

                fetchWorkoutExisting(date.toString().split(' ')[0]);
              },
              child: const Icon(Icons.add),
            ),
          ),
          bottomNavigationBar: Visibility(
            visible: !isWorkoutExisting && !isLoading,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (UserPreferences.getVibrate() == true) {
                      Vibrate.feedback(FeedbackType.heavy);
                    }
                    await DatabaseHelper.instance.addWorkout(
                      WorkoutData(
                          date: date.toString().split(' ')[0],
                          timestamp: DateTime.now().toString()),
                    );

                    fetchWorkoutExisting(date.toString().split(' ')[0]);
                    fetchExerciseData();
                  },
                  child: const Text(
                    'Create Workout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
