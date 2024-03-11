import 'dart:async';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:training_log_app/utility/one_rep_max_calculator.dart';
import 'package:training_log_app/pages/workout.dart';
import 'package:training_log_app/provider/navigation_provider.dart';
import 'package:provider/provider.dart';
import '../models/navigation_model.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import 'package:training_log_app/pages/edit_exercise.dart';
import 'package:training_log_app/models/exercise_model.dart';

class SingleExerciseTabs extends StatefulWidget {
  final String exercise;

  const SingleExerciseTabs({super.key, required this.exercise});

  @override
  State<StatefulWidget> createState() => _SingleExerciseTabs();
}

class _SingleExerciseTabs extends State<SingleExerciseTabs> {
  late var allWorkouts = [];
  late var uniqueDates = [];
  late int exerciseId;
  late String exerciseName = '';
  late String imageUrl = '';
  late String bodyPart = '';
  late String target = '';
  late String equipment = '';
  late bool isFavorite = false;
  late bool isCustom = false;

  //  history tab
  List<String> dropDownItemsHistory = ['Ascending', 'Descending'];
  String? dropDownSelectedHistory = 'Ascending';

  // stats tab
  List<String> dropDownItems = ['Volume', 'Sets', 'Reps', 'One Rep Max'];
  String? dropDownSelected = 'Volume';
  late double maxVolume = 0.0;
  late double minVolume = 0.0;
  late double maxSets = 0.0;
  late double minSets = 0.0;
  late double maxReps = 0.0;
  late double minReps = 0.0;
  late double highestOneRepMax = 0.0;
  late double lowestOneRepMax = 0.0;

  @override
  void initState() {
    super.initState();

    fetchWorkouts(widget.exercise);
  }

  //
  void setExerciseName(String name) {
    setState(() {
      exerciseName = name;
    });
  }

  // Get all workouts from the workouts db table
  void fetchWorkouts(String name) async {
    Map dateMap = {};
    var result =
        await DatabaseHelper.instance.getWorkoutsAllSpecificExerciseData(name);

    // Get exercises added to workout.
    for (var item in result) {
      if (!dateMap.containsKey(item['date'])) {
        dateMap[item['date']] = null;
      }
    }

    var data = await DatabaseHelper.instance.getSpecificExercise(name);

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      allWorkouts = result;
      uniqueDates = dateMap.keys.toList();
      exerciseId = data[0].id!;
      exerciseName = data[0].name;
      imageUrl = data[0].image!;
      bodyPart = data[0].bodyPart;
      target = data[0].target;
      equipment = data[0].equipment;
      isFavorite = data[0].isFavorite == 0 ? false : true;
      isCustom = data[0].isCustom == 0 ? false : true;
    });
  }

  // Build a widget responsible fro displaying Volume data on line chart.
  Widget buildVolumeLineChart(BuildContext context) {
    Map volumes = {};

    for (var item in allWorkouts) {
      if (!volumes.containsKey(item['date'])) {
        volumes[item['date']] =
            double.parse(item['weight']) * double.parse(item['reps']);
      } else {
        volumes[item['date']] = volumes[item['date']] +
            (double.parse(item['weight']) * double.parse(item['reps']));
      }
    }

    // Get max Y and max X.
    double maxX = volumes.length.toDouble() - 1.0;
    double maxY = 0.0;
    double minY = 0.0;

    for (var num in volumes.values) {
      if (num > maxY) {
        maxY = num;
      }
    }

    // Set minY to maxY to start since we need to find the smallest number
    minY = maxY;

    for (var num in volumes.values) {
      if (num < minY) {
        minY = num;
      }
    }

    setState(() {
      maxVolume = maxY;
      minVolume = minY;
    });

    //spots
    List<FlSpot> spots = [];
    int spotCount = 0;
    volumes.forEach((key, value) {
      spots.add(FlSpot(spotCount.toDouble(), value));
      spotCount++;
    });

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 0.0,
          maxX: maxX,
          minY: 0.0,
          maxY: (maxY / 1000).ceilToDouble() * 1000,
          titlesData: const FlTitlesData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSetsLineChart(BuildContext context) {
    Map sets = {};

    for (var item in allWorkouts) {
      if (!sets.containsKey(item['date'])) {
        sets[item['date']] = 1.0;
      } else {
        sets[item['date']] += 1.0;
      }
    }

    // Get max Y and max X.
    double maxX = sets.length.toDouble() - 1.0;
    double maxY = 0.0;
    double minY = 0.0;

    for (var num in sets.values) {
      if (num > maxY) {
        maxY = num;
      }
    }

    // Set minY to maxY to start since we need to find the smallest number
    minY = maxY;

    for (var num in sets.values) {
      if (num < minY) {
        minY = num;
      }
    }

    setState(() {
      maxSets = maxY;
      minSets = minY;
    });

    //spots
    List<FlSpot> spots = [];
    int spotCount = 0;
    sets.forEach((key, value) {
      spots.add(FlSpot(spotCount.toDouble(), value));
      spotCount++;
    });

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 0.0,
          maxX: maxX,
          minY: 0.0,
          maxY: (maxY / 10).ceilToDouble() * 10,
          titlesData: const FlTitlesData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRepsLineChart(BuildContext context) {
    Map reps = {};

    for (var item in allWorkouts) {
      if (!reps.containsKey(item['date'])) {
        reps[item['date']] = double.parse(item['reps']);
      } else {
        reps[item['date']] = reps[item['date']] + double.parse(item['reps']);
      }
    }

    // Get max Y and max X.
    double maxX = reps.length.toDouble() - 1.0;
    double maxY = 0.0;
    double minY = 0.0;

    for (var num in reps.values) {
      if (num > maxY) {
        maxY = num;
      }
    }

    // Set minY to maxY to start since we need to find the smallest number
    minY = maxY;

    for (var num in reps.values) {
      if (num < minY) {
        minY = num;
      }
    }

    setState(() {
      maxReps = maxY;
      minReps = minY;
    });

    //spots
    List<FlSpot> spots = [];
    int spotCount = 0;
    reps.forEach((key, value) {
      spots.add(FlSpot(spotCount.toDouble(), value));
      spotCount++;
    });

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 0.0,
          maxX: maxX,
          minY: 0.0,
          maxY: (maxY / 10).ceilToDouble() * 10,
          titlesData: const FlTitlesData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOneRepMaxLineChart(BuildContext context) {
    Map oneRepMaxes = {};

    for (var item in allWorkouts) {
      if (!oneRepMaxes.containsKey(item['date'])) {
        oneRepMaxes[item['date']] = double.parse(OneRepMaxCalculator(
                weight: double.parse(item['weight']),
                reps: int.parse(item['reps']))
            .getOneRepMaxBrzyckiFormula()
            .toStringAsFixed(2));
      } else {
        var newOneRepMax = double.parse(OneRepMaxCalculator(
                weight: double.parse(item['weight']),
                reps: int.parse(item['reps']))
            .getOneRepMaxBrzyckiFormula()
            .toStringAsFixed(2));

        if (oneRepMaxes[item['date']] < newOneRepMax) {
          oneRepMaxes[item['date']] = newOneRepMax;
        }
      }
    }

    // Get max Y and max X.
    double maxX = oneRepMaxes.length.toDouble() - 1.0;
    double maxY = 0.0;
    double minY = 0.0;

    for (var num in oneRepMaxes.values) {
      if (num > maxY) {
        maxY = num;
      }
    }

    // Set minY to maxY to start since we need to find the smallest number
    minY = maxY;

    for (var num in oneRepMaxes.values) {
      if (num < minY) {
        minY = num;
      }
    }

    setState(() {
      highestOneRepMax = maxY;
      lowestOneRepMax = minY;
    });

    //spots
    List<FlSpot> spots = [];
    int spotCount = 0;
    oneRepMaxes.forEach((key, value) {
      spots.add(FlSpot(spotCount.toDouble(), value));
      spotCount++;
    });

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 0.0,
          maxX: maxX,
          minY: 0.0,
          maxY: (maxY / 100).ceilToDouble() * 100,
          titlesData: const FlTitlesData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoTab(BuildContext context) {
    if (imageUrl == '') {
      return const Center(
        child: SpinKitCircle(
          size: 140,
          color: Colors.blue,
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
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
                            'Body Part',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )),
                          DataCell(Text(
                            bodyPart,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )),
                        ],
                        onLongPress: () {},
                      ),
                      DataRow(
                        cells: [
                          const DataCell(Text(
                            'Target',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )),
                          DataCell(Text(
                            target,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )),
                        ],
                        onLongPress: () {},
                      ),
                      DataRow(
                        cells: [
                          const DataCell(Text(
                            'Equipment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )),
                          DataCell(Text(
                            equipment,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )),
                        ],
                        onLongPress: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget buildHistoryTab(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButton(
              isExpanded: true,
              value: dropDownSelectedHistory,
              items: dropDownItemsHistory
                  .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 20),
                      )))
                  .toList(),
              onChanged: (item) {
                setState(() {
                  dropDownSelectedHistory = item.toString();
                  uniqueDates = List.from(uniqueDates.reversed);
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: uniqueDates.map((item) {
                return FocusedMenuHolder(
                  blurSize: 0,
                  openWithTap: false,
                  onPressed: () {},
                  menuItems: [
                    FocusedMenuItem(
                      title: const Text('Workout'),
                      backgroundColor: Colors.blueAccent,
                      onPressed: () {
                        if (UserPreferences.getVibrate() == true) {
                          Vibrate.feedback(FeedbackType.heavy);
                        }

                        var date = DateTime.parse(item);
                        // set drawer menu item selected
                        final provider = Provider.of<NavigationProvider>(
                            context,
                            listen: false);
                        provider.setNavigationItem(NavigationItem.workout);

                        // Navigate
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => WorkoutPage(dateToLoad: date),
                        ));
                      },
                      trailingIcon: const Icon(Icons.work),
                    ),
                  ],
                  child: Column(
                    children: [
                      Card(
                        child: ExpansionTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                label: Text(
                                  item.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                labelPadding: const EdgeInsets.all(4),
                                avatar: const CircleAvatar(
                                  child: Icon(Icons.calendar_month),
                                ),
                              ),
                            ],
                          ),
                          children:
                              buildExerciseTiles(context, item.toString()),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsTab(BuildContext context) {
    var totalVolume = 0.0;
    var totalReps = 0;

    for (var item in allWorkouts) {
      totalVolume += double.parse(item['weight']) * double.parse(item['reps']);
      totalReps += int.parse(item['reps']);
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
              child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              if (dropDownSelected == 'Volume') buildVolumeLineChart(context),
              if (dropDownSelected == 'Volume')
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
                        const DataCell(
                          Text(
                            'Total Volume',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$totalVolume',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Max Daily Volume',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$maxVolume',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Min Daily Volume',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$minVolume',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                  ],
                ),
              if (dropDownSelected == 'Sets') buildSetsLineChart(context),
              if (dropDownSelected == 'Sets')
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
                        const DataCell(
                          Text(
                            'Total Sets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${allWorkouts.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Max Daily Sets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$maxSets',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Min Daily Sets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$minSets',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                  ],
                ),
              if (dropDownSelected == 'Reps') buildRepsLineChart(context),
              if (dropDownSelected == 'Reps')
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
                        const DataCell(
                          Text(
                            'Total Reps',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$totalReps',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Max Daily Reps',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$maxReps',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Min Daily Reps',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$minReps',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                  ],
                ),
              if (dropDownSelected == 'One Rep Max')
                buildOneRepMaxLineChart(context),
              if (dropDownSelected == 'One Rep Max')
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
                        const DataCell(
                          Text(
                            'Highest',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$highestOneRepMax',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'Lowest',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '$lowestOneRepMax',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                      onLongPress: () {},
                    ),
                  ],
                ),
            ],
          )),
        ],
      ),
    );
  }

  List<Widget> buildExerciseTiles(BuildContext context, String date) {
    var tiles = <Widget>[];
    var setCount = 0;

    for (var item in allWorkouts) {
      var weight = item['weight'];
      var reps = item['reps'];

      if (item['date'] == date) {
        setCount++;
        tiles.add(ListTile(
          title: Text(
              'Set: ${setCount.toString()} | Weight: ${weight.toString()} | Reps: ${reps.toString()}'),
        ));
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(exerciseName),
          actions: [
            if (isCustom)
              IconButton(
                onPressed: () async {
                  if (UserPreferences.getVibrate() == true) {
                    Vibrate.feedback(FeedbackType.heavy);
                  }

                  // Navigate
                  await Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) => EditExercisePage(
                        exerciseData: Exercise(
                          id: exerciseId,
                          name: exerciseName,
                          bodyPart: bodyPart,
                          target: target,
                          equipment: equipment,
                        ),
                        setExerciseName: setExerciseName),
                  ))
                      .then((value) {
                    fetchWorkouts(exerciseName);
                  });
                },
                icon: const Icon(Icons.edit),
              ),
            if (isCustom)
              IconButton(
                onPressed: () {
                  if (UserPreferences.getVibrate() == true) {
                    Vibrate.feedback(FeedbackType.heavy);

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Exercise'),
                        content: const Text(
                            'Clicking OK will delete this exercise from the Database forever!'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              // Delete custom exercise from database

                              // close pop up
                              Navigator.pop(context);
                              // Navigate
                              Navigator.of(context).pop();
                              // Delete exercise
                              await DatabaseHelper.instance
                                  .removeExercise(exerciseId);
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
              Tab(
                text: 'INFO',
              ),
              Tab(
                text: 'HISTORY',
              ),
              Tab(
                text: 'STATS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildInfoTab(context),
            buildHistoryTab(context),
            buildStatsTab(context),
          ],
        ),
      ),
    );
  }
}
