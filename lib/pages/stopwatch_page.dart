import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../utility/user_preferences.dart';
import '../widgets/app_drawer.dart';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  State<StatefulWidget> createState() => _StopWatchPage();
}

class _StopWatchPage extends State<StopWatchPage> {
  // timer object
  late Timer timer;

  // check if active
  bool isTimerRunning = false;

  // time to display
  String timerStopwatch = '00:00:00';

  // hours, minutes, seconds all converted to seconds
  int allSeconds = 0;
  int maxSeconds = 0;

  // For stopwatch
  int stopwatchCount = 0;

  // controllers
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  final secondsController = TextEditingController();

  List<String> dropDownItems = ['Stopwatch', 'Timer'];
  String? dropDownSelected = 'Stopwatch';

  @override
  void initState() {
    super.initState();
  }

  String intToTimeLeft(int value) {
    int hour = value ~/ 3600;
    int month = ((value - hour * 3600)) ~/ 60;
    int seconds = value - (hour * 3600) - (month * 60);

    String hourLeft = hour.toString().length < 2 ? '0$hour' : hour.toString();
    String minuteLeft =
        month.toString().length < 2 ? '0$month' : month.toString();
    String secondsLeft =
        seconds.toString().length < 2 ? '0$seconds' : seconds.toString();

    return "$hourLeft:$minuteLeft:$secondsLeft";
  }

  // Used for the timer UI
  Widget buildTimer(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: maxSeconds > 0 ? 1 - (allSeconds / maxSeconds) : 0,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 15,
                  backgroundColor: Colors.redAccent,
                ),
                Center(
                  child: Text(
                    timerStopwatch,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: minutesController,
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: secondsController,
                decoration: const InputDecoration(
                  labelText: 'Seconds',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Used for the stopwatch UI.
  Widget buildStopwatch(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: stopwatchCount / 60,
              valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
              strokeWidth: 15,
              backgroundColor: Colors.white,
            ),
            Center(
              child: Text(
                timerStopwatch,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch Timer'),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: Center(
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
                onChanged: (item) {
                  if (isTimerRunning) {
                    // stop the timer
                    timer.cancel();
                  }

                  setState(() {
                    allSeconds = 0;
                    maxSeconds = 0;
                    timerStopwatch = intToTimeLeft(0);
                    isTimerRunning = false;
                    stopwatchCount = 0;
                  });

                  setState(() {
                    dropDownSelected = item.toString();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  if (dropDownSelected == 'Stopwatch') buildStopwatch(context),
                  if (dropDownSelected == 'Timer') buildTimer(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // put color here?
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          if (!isTimerRunning) {
                            setState(() {
                              isTimerRunning = true;
                            });
                            // only do this if timer option is selected
                            if (dropDownSelected == 'Timer') {
                              setState(() {
                                hoursController.text =
                                    hoursController.text == '' ||
                                            hoursController.text.isEmpty
                                        ? '0'
                                        : hoursController.text;
                                minutesController.text =
                                    minutesController.text == '' ||
                                            minutesController.text.isEmpty
                                        ? '0'
                                        : minutesController.text;
                                secondsController.text =
                                    secondsController.text == '' ||
                                            secondsController.text.isEmpty
                                        ? '0'
                                        : secondsController.text;
                              });
                              if ((hoursController.text.isEmpty &&
                                      minutesController.text.isEmpty &&
                                      secondsController.text.isEmpty) ||
                                  (hoursController.text == '' &&
                                      minutesController.text == '' &&
                                      secondsController.text == '') ||
                                  (hoursController.text == '0' &&
                                      minutesController.text == '0' &&
                                      secondsController.text == '0')) {
                                setState(() {
                                  isTimerRunning = false;
                                });
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title:
                                              const Text('Missing information'),
                                          content: const Text(
                                              'Please enter information in all fields!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ));
                              } else {
                                if (allSeconds < 1) {
                                  setState(() {
                                    allSeconds =
                                        (int.parse(hoursController.text) *
                                                3600) +
                                            (int.parse(minutesController.text) *
                                                60) +
                                            int.parse(secondsController.text);
                                    timerStopwatch = intToTimeLeft(allSeconds);
                                  });
                                  maxSeconds =
                                      (int.parse(hoursController.text) * 3600) +
                                          (int.parse(minutesController.text) *
                                              60) +
                                          int.parse(secondsController.text);
                                }

                                timer = Timer.periodic(
                                    const Duration(seconds: 1), (timer) {
                                  setState(() {
                                    if (allSeconds != 0) {
                                      allSeconds--;
                                      timerStopwatch =
                                          intToTimeLeft(allSeconds);
                                    } else {
                                      isTimerRunning = false;
                                      timer.cancel();
                                      if (UserPreferences.getVibrate() ==
                                          true) {
                                        Vibrate.vibrateWithPauses([
                                          const Duration(milliseconds: 500),
                                          const Duration(milliseconds: 500),
                                        ]);
                                      }
                                    }
                                  });
                                });
                              }
                            }

                            // only do this if stop watch option is selected
                            if (dropDownSelected == 'Stopwatch') {
                              setState(() {
                                timerStopwatch = intToTimeLeft(allSeconds);
                              });

                              timer = Timer.periodic(const Duration(seconds: 1),
                                  (timer) {
                                setState(() {
                                  allSeconds++;
                                  timerStopwatch = intToTimeLeft(allSeconds);
                                  if (stopwatchCount == 60) {
                                    stopwatchCount = 0;
                                  }
                                  stopwatchCount++;
                                });
                              });
                            }
                          }
                        },
                        child: const Text('Start'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // put color here?
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          if (isTimerRunning) {
                            // stop the timer
                            timer.cancel();
                            setState(() {
                              isTimerRunning = false;
                            });
                          }
                        },
                        child: const Text('Stop'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // put color here?
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          if (UserPreferences.getVibrate() == true) {
                            Vibrate.feedback(FeedbackType.heavy);
                          }

                          if (isTimerRunning) {
                            // stop the timer
                            timer.cancel();
                          }

                          setState(() {
                            allSeconds = 0;
                            maxSeconds = 0;
                            timerStopwatch = intToTimeLeft(0);
                            isTimerRunning = false;
                            stopwatchCount = 0;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
