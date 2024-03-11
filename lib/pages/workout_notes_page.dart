import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import 'package:training_log_app/models/note_model.dart';
import 'package:training_log_app/widgets/custom_snackbars.dart';

class WorkoutNotesPage extends StatefulWidget {
  final int workoutId;

  const WorkoutNotesPage({super.key, required this.workoutId});

  @override
  State<StatefulWidget> createState() => _WorkoutNotesPage();
}

class _WorkoutNotesPage extends State<WorkoutNotesPage> {
  // controllers
  TextEditingController notesController = TextEditingController();

  bool updateNote = false;

  @override
  void initState() {
    super.initState();

    fetchWorkoutNote();
  }

  void fetchWorkoutNote() async {
    var query = await DatabaseHelper.instance.getWorkoutNote(widget.workoutId);

    if (query.isNotEmpty) {
      setState(() {
        notesController.text = query[0].note;
        debugPrint(query[0].note);
        updateNote = true;
      });
    } else {
      setState(() {
        updateNote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Notes'),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Scrollbar(
            child: TextField(
              controller: notesController,
              keyboardType: TextInputType.multiline,
              maxLines: 99999,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: SizedBox(
          height: 50,
          child: OutlinedButton(
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              if (UserPreferences.getVibrate() == true) {
                Vibrate.feedback(FeedbackType.heavy);
              }

              if (updateNote) {
                await DatabaseHelper.instance.updateWorkoutNote(
                    widget.workoutId,
                    notesController.text,
                    DateTime.now().toString());
              } else {
                await DatabaseHelper.instance.addNote(Note(
                    workoutId: widget.workoutId,
                    note: notesController.text,
                    timestamp: DateTime.now().toString()));
              }

              if (!mounted) return;
              Navigator.pop(context);

              if (!updateNote) {
                ShowCustomSnackBars.showWorkoutNoteAddedSnackBar(context);
              } else {
                ShowCustomSnackBars.showWorkoutNoteUpdatedSnackBar(context);
              }


            },
          ),
        ),
      ),
    );
  }
}
