import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/models/exercise_model.dart';
import 'package:training_log_app/utility/user_preferences.dart';

class CreateExercisePage extends StatefulWidget {
  const CreateExercisePage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateExercisePage();
}

class _CreateExercisePage extends State<CreateExercisePage> {
  // controllers
  final nameController = TextEditingController();
  final bodyPartController = TextEditingController();
  final targetController = TextEditingController();
  final equipmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20, top: 20),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Fill out the form below to create a custom exercise!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Image.asset('assets/media/dumbbell-animated.gif'),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: bodyPartController,
                  decoration: const InputDecoration(
                    labelText: 'Body Part',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: targetController,
                  decoration: const InputDecoration(
                    labelText: 'Target',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: equipmentController,
                  decoration: const InputDecoration(
                    labelText: 'Equipment',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
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

              // check if exercise already exists
              bool isExisting = await DatabaseHelper.instance
                  .isExerciseExisting(nameController.text);

              if (nameController.text.isEmpty ||
                  bodyPartController.text.isEmpty ||
                  targetController.text.isEmpty ||
                  equipmentController.text.isEmpty) {
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
              } else if (isExisting) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exercise already exists'),
                    content: const Text(
                        'The exercise already exists in the database!'),
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
                DatabaseHelper.instance.addExercise(Exercise(
                    name: nameController.text,
                    bodyPart: bodyPartController.text,
                    target: targetController.text,
                    equipment: equipmentController.text,
                    image: 'assets/media/dumbbell-animated.gif',
                    isFavorite: 0,
                    isCustom: 1));

                if (!mounted) return;
                // navigate
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add Exercise',
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
