import 'package:flutter/material.dart';
import 'package:training_log_app/utility/one_rep_max_calculator.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:training_log_app/utility/user_preferences.dart';

import '../widgets/app_drawer.dart';

class OneRepMaxPage extends StatefulWidget {
  const OneRepMaxPage({super.key});

  @override
  State<StatefulWidget> createState() => _OneRepMaxPage();
}

class _OneRepMaxPage extends State<OneRepMaxPage> {
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final percentages = [100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50];
  final repetitions = [1, 2, 4, 6, 8, 10, 12, 16, 20, 24, 30];
  List<dynamic> weightsPercent = [];
  List<String> dropDownItems = ['Brzycki', 'Epley', 'Lombardi', "O'Conner"];
  String? dropDownSelected = 'Brzycki';

  double oneRepMax = 0.0;

  void calculateOneRepMax() {
    double result = 0.0;

    var repCalc = OneRepMaxCalculator(
        weight: double.parse(weightController.text),
        reps: int.parse(repsController.text));

    if (dropDownSelected == 'Brzycki') {
      result = repCalc.getOneRepMaxBrzyckiFormula();
    } else if (dropDownSelected == 'Epley') {
      result = repCalc.getOneRepMaxEpleyFormula();
    } else if (dropDownSelected == 'Lombardi') {
      result = repCalc.getOneRepMaxLombardiFormula();
    } else if (dropDownSelected == "O'Conner") {
      result = repCalc.getOneRepMaxOconnerFormula();
    }

    List<dynamic> numbers = [];

    for (var num in percentages) {
      if (num == 100) {
        numbers.add(double.parse(result.toStringAsFixed(2)));
      } else {
        numbers.add((((num / 100) * result)).toStringAsFixed(2));
      }
    }

    setState(() {
      oneRepMax = double.parse(result.toStringAsFixed(2));
      weightsPercent = numbers;
    });
  }

  DataTable buildDataTable(BuildContext context) {
    late List<DataRow> rows = [];

    for (var i = 0; i < weightsPercent.length; i++) {
      if (i != 0) {
        rows.add(
          DataRow(cells: [
            DataCell(Text('${percentages[i]}%')),
            DataCell(Text('${weightsPercent[i]}')),
            DataCell(Text('${repetitions[i]}')),
          ]),
        );
      } else {
        rows.add(
          DataRow(cells: [
            DataCell(Text(
              '${percentages[i]}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
            DataCell(Text(
              '${weightsPercent[i]}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
            DataCell(Text(
              '${repetitions[i]}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
          ]),
        );
      }
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('% of 1RM')),
        DataColumn(label: Text('Weight')),
        DataColumn(label: Text('Reps')),
      ],
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Rep Max Calculator'),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.science),
                      ),
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
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
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
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  if (weightsPercent.isNotEmpty) buildDataTable(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (UserPreferences.getVibrate() == true) {
                Vibrate.feedback(FeedbackType.heavy);
              }

              if (weightController.text.isEmpty ||
                  repsController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Missing information'),
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
                  ),
                );
              } else {
                calculateOneRepMax();
              }
            },
            child: const Text(
              'Calculate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}
