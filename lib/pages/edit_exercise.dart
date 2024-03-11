import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:training_log_app/models/exercise_model.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import 'package:training_log_app/db/database_helper.dart';

class EditExercisePage extends StatefulWidget {
  final Exercise exerciseData;
  final Function setExerciseName;

  const EditExercisePage({super.key, required this.exerciseData, required this.setExerciseName});

  @override
  State<StatefulWidget> createState() => _EditExercisePage();
}

class _EditExercisePage extends State<EditExercisePage> {
  // controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController bodyPartController = TextEditingController();
  TextEditingController targetController = TextEditingController();
  TextEditingController equipmentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.text = widget.exerciseData.name;
    bodyPartController.text = widget.exerciseData.bodyPart;
    targetController.text = widget.exerciseData.target;
    equipmentController.text = widget.exerciseData.equipment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseData.name),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: bodyPartController,
                      decoration: const InputDecoration(
                        labelText: 'Body Part',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: targetController,
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: equipmentController,
                      decoration: const InputDecoration(
                        labelText: 'Equipment',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (UserPreferences.getVibrate() == true) {
                Vibrate.feedback(FeedbackType.heavy);
              }

              await DatabaseHelper.instance.editExercise(
                widget.exerciseData.id!,
                nameController.text.isNotEmpty
                    ? nameController.text
                    : widget.exerciseData.name,
                bodyPartController.text.isNotEmpty
                    ? bodyPartController.text
                    : widget.exerciseData.bodyPart,
                targetController.text.isNotEmpty
                    ? targetController.text
                    : widget.exerciseData.target,
                equipmentController.text.isNotEmpty
                    ? equipmentController.text
                    : widget.exerciseData.equipment,
              );

              await widget.setExerciseName(nameController.text);

              if (!mounted) return;
              // Navigate
              Navigator.pop(context);
            },
            child: const Text(
              'Edit Exercise',
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
