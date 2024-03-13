import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:training_log_app/pages/workout.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/provider/navigation_provider.dart';
import 'package:provider/provider.dart';
import '../models/navigation_model.dart';
import '../widgets/app_drawer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:training_log_app/utility/user_preferences.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarPage();
}

class _CalendarPage extends State<CalendarPage> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  late var allWorkoutsMonthYear = [];
  late List<dynamic> datesToHighlight = [];

  @override
  void initState() {
    super.initState();
    getDaysToHighlight(DateTime.now().toString().split(' ')[0].substring(0, 7));
  }

  void getDaysToHighlight(String yearMonth) async {
    var result = await DatabaseHelper.instance
        .getWorkoutsAllSpecificYearMonth(yearMonth);
    var dates = [];

    for (var date in result) {
      dates.add(date['date']);
    }

    setState(() {
      datesToHighlight = dates.toSet().toList();
      allWorkoutsMonthYear = result;
    });
  }

  List<Widget> buildExerciseExpansionTiles(BuildContext context, String date) {
    var tiles = <Widget>[];
    Map exerciseMap = {};
    List uniqueExercises = [];

    for (var item in allWorkoutsMonthYear) {
      if (item['date'] == date) {
        if (!exerciseMap.containsKey(item['name'])) {
          exerciseMap[item['name']] = [
            1,
            item['isFavorite']
          ]; // create list that holds set count and isFavorite
        } else {
          exerciseMap[item['name']][0]++; // add 1 to set count
        }
      }
    }

    uniqueExercises = exerciseMap.keys.toList();

    for (var exercise in uniqueExercises) {
      tiles.add(
        ExpansionTile(
          leading: badges.Badge(
            badgeContent: Text(exerciseMap[exercise][0].toString()),
            child: exerciseMap[exercise][1] == 1
                ? const Icon(
                    Icons.star,
                    color: Colors.amber,
                  )
                : const Icon(Icons.fitness_center),
          ),
          title: Text(exercise),
          children: buildExerciseTiles(date, exercise),
        ),
      );
    }
    return tiles;
  }

  List<Widget> buildExerciseTiles(String date, String exercise) {
    var tiles = <Widget>[];
    var setCount = 0;

    for (var item in allWorkoutsMonthYear) {
      if (item['date'] == date && item['name'] == exercise) {
        setCount++;
        tiles.add(ListTile(
          title: Text(
              'Set: ${setCount.toString()} | Weight: ${item['weight'].toString()} | Reps: ${item['reps'].toString()}'),
        ));
      }
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(children: [
                TableCalendar(
                  focusedDay: selectedDay,
                  firstDay: DateTime(1990),
                  lastDay: DateTime(2050),
                  calendarFormat: calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      calendarFormat = format;
                    });
                  },
                  onPageChanged: ((focusedDay) {
                    selectedDay = focusedDay;
                    getDaysToHighlight(
                        focusedDay.toString().split(' ')[0].substring(0, 7));
                  }),
                  onDaySelected: (DateTime selectDay, DateTime focusDay) async {
                    setState(() {
                      selectedDay = selectDay;
                      focusedDay = focusDay;
                    });
                    getDaysToHighlight(
                        focusedDay.toString().split(' ')[0].substring(0, 7));

                    if (UserPreferences.getVibrate() == true) {
                      Vibrate.feedback(FeedbackType.heavy);
                    }

                    // set drawer menu item selected
                    final provider =
                        Provider.of<NavigationProvider>(context, listen: false);
                    provider.setNavigationItem(NavigationItem.workout);

                    await Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (context) =>
                              WorkoutPage(dateToLoad: selectedDay),
                        ))
                        .then((value) => setState(() {
                              getDaysToHighlight(focusedDay
                                  .toString()
                                  .split(' ')[0]
                                  .substring(0, 7));
                            }));
                  },
                  selectedDayPredicate: (DateTime date) {
                    return isSameDay(selectedDay, date);
                  },
                  calendarStyle: const CalendarStyle(
                    isTodayHighlighted: false,
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                  ),
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, focusedDay) {
                    for (var item in datesToHighlight) {
                      if (date.toString().split(' ')[0] == item) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  date.day.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const Positioned(
                                bottom: 2,
                                left: 2,
                                child: Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                    return null;
                  }),
                ),
                // expansion tiles list of dates
                ...datesToHighlight.map((item) {
                  return Column(
                    children: [
                      FocusedMenuHolder(
                        blurSize: 0,
                        openWithTap: false,
                        onPressed: () {},
                        menuItems: [
                          FocusedMenuItem(
                            title: const Text('Workout'),
                            backgroundColor: Colors.blueAccent,
                            trailingIcon: const Icon(Icons.work),
                            onPressed: () {
                              if (UserPreferences.getVibrate() == true) {
                                Vibrate.feedback(FeedbackType.heavy);
                              }

                              var date = DateTime.parse(item);
                              // set drawer menu item selected
                              final provider = Provider.of<NavigationProvider>(
                                  context,
                                  listen: false);
                              provider
                                  .setNavigationItem(NavigationItem.workout);

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutPage(dateToLoad: date),
                              ));
                            },
                          ),
                        ],
                        child: Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Card(
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
                              children: buildExerciseExpansionTiles(
                                  context, item.toString()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
