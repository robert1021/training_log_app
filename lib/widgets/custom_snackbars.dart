import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ShowCustomSnackBars {


  static void showSetAddedSnackBar(BuildContext context) => Flushbar(
    backgroundColor: Colors.green.withOpacity(0.85),
    shouldIconPulse: false,
    message: 'Set added!',
    duration: const Duration(seconds: 1),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0),
  )..show(context);


  static void showRoutineAddedSnackBar(BuildContext context) => Flushbar(
    backgroundColor: Colors.green.withOpacity(0.85),
    shouldIconPulse: false,
    message: 'Routine added!',
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0),

  )..show(context);

  static void showWorkoutNoteAddedSnackBar(BuildContext context) => Flushbar(
    backgroundColor: Colors.green.withOpacity(0.85),
    shouldIconPulse: false,
    message: 'Note added!',
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0),

  )..show(context);

  static void showWorkoutNoteUpdatedSnackBar(BuildContext context) => Flushbar(
    backgroundColor: Colors.green.withOpacity(0.85),
    shouldIconPulse: false,
    message: 'Note updated!',
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0),

  )..show(context);




}
