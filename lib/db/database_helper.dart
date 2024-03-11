import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:training_log_app/models/exercise_model.dart';
import 'package:training_log_app/models/set_model.dart';
import 'package:training_log_app/models/workout_model.dart';
import 'package:training_log_app/models/routine_model.dart';
import 'package:training_log_app/models/routine_set_model.dart';
import '../models/reminder_model.dart';
import 'package:training_log_app/models/note_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'workoutApp.db');

    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onConfigure: _onConfigure);
  }

  _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future _onCreate(Database db, int version) async {
    // create workouts table
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    // create exercises table
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bodyPart TEXT NOT NULL,
        target TEXT NOT NULL,
        equipment TEXT NOT NULL,
        image TEXT,
        isFavorite INTEGER NOT NULL,
        isCustom INTEGER NOT NULL
      )
    ''');
    // create sets table
    await db.execute('''
      CREATE TABLE sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        weight TEXT NOT NULL,
        reps TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(workoutId) REFERENCES workouts(id) ON DELETE CASCADE,
        FOREIGN KEY(exerciseId) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');

    // create routines table
    await db.execute('''
      CREATE TABLE routines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // create routineSets table
    await db.execute('''
      CREATE TABLE routineSets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        name TEXT NOT NULL,
        weight TEXT NOT NULL,
        reps TEXT NOT NULL,
        FOREIGN KEY(routineId) REFERENCES routines(id) ON DELETE CASCADE,
        FOREIGN KEY(exerciseId) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');

    // create reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isOn INTEGER NOT NULL,
        time TEXT NOT NULL,
        monday INTEGER NOT NULL,
        tuesday INTEGER NOT NULL,
        wednesday INTEGER NOT NULL,
        thursday INTEGER NOT NULL,
        friday INTEGER NOT NULL,
        saturday INTEGER NOT NULL,
        sunday INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // create workoutNotes table
    await db.execute('''
      CREATE TABLE workoutNotes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL,
        note TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(workoutId) REFERENCES workouts(id) ON DELETE CASCADE
      )
    ''');

    // insert initial exercise data from JSON file
    _insertInitialExerciseData(db);
  }

  // Adds all exercise data from JSON file into [db].
  Future _insertInitialExerciseData(Database db) async {
    final data = await rootBundle.loadString('assets/exercises.json');
    List jsonData = jsonDecode(data);

    for (var element in jsonData) {
      Map<String, Object?> exercise = {
        'name': element['name'],
        'bodyPart': element['bodyPart'],
        'target': element['target'],
        'equipment': element['equipment'],
        'image': element['gifUrl'],
        'isFavorite': 0,
        'isCustom': 0,
      };

      await db.insert('exercises', exercise);
    }
  }

  // workouts table queries

  // Insert new workout into workouts table.
  Future<int> addWorkout(WorkoutData workout) async {
    Database db = await instance.database;

    return await db.insert('workouts', workout.toMap());
  }

  // Checks the workouts table to see if a specific workout exists.
  // The [date] should be unique for each workout.
  Future<bool> isWorkoutExisting(String date) async {
    Database db = await instance.database;

    var query = await db.rawQuery('''
      SELECT * FROM workouts
      WHERE date = ?
      
    ''', [date]);

    bool isExisting = query.isNotEmpty ? true : false;

    return isExisting;
  }

  // Gets first matching workout from workouts table.
  // Uses [date] to query.
  Future<List<WorkoutData>> getWorkout(String date) async {
    Database db = await instance.database;

    var query = await db.rawQuery('''
      SELECT * FROM workouts
      WHERE date = ?
      limit 1
    ''', [date]);

    List<WorkoutData> workoutList = query.isNotEmpty
        ? query.map((workout) => WorkoutData.fromMap(workout)).toList()
        : [];

    return workoutList;
  }

  // Gets all workout data from workouts table.
  Future<List<WorkoutData>> getWorkouts() async {
    Database db = await instance.database;
    var workouts = await db.query('workouts', orderBy: 'date');

    List<WorkoutData> workoutList = workouts.isNotEmpty
        ? workouts.map((workout) => WorkoutData.fromMap(workout)).toList()
        : [];

    return workoutList;
  }

  // Gets all workout data joined with workouts | sets | exercises.
  // For a specific year and month.
  Future<List<Map>> getWorkoutsAllSpecificYearMonth(String yearMonth) async {
    Database db = await instance.database;
    List<Map> workouts = await db.rawQuery('''
      SELECT workoutID, date, exerciseId, name, sets.id as setId, weight, reps, exercises.isFavorite as isFavorite
      FROM workouts
      INNER JOIN sets
      ON workouts.id = sets.workoutId
      INNER JOIN exercises
      ON sets.exerciseId = exercises.id
      WHERE SUBSTR(date, 1, 7) = ?
      ORDER BY date ASC
    ''', [yearMonth]);

    return workouts;
  }

  // Gets all workout data joined with workouts | sets | exercises.
  Future<List<Map>> getWorkoutsAllSpecificData(int workoutId) async {
    Database db = await instance.database;
    List<Map> workouts = await db.rawQuery('''
      SELECT workoutID, date, exerciseId, name, sets.id as setId, weight, reps
      FROM workouts
      INNER JOIN sets
      ON workouts.id = sets.workoutId
      INNER JOIN exercises
      ON sets.exerciseId = exercises.id
      WHERE workouts.id = ?
    ''', [workoutId]);

    return workouts;
  }

  // Gets all workout data joined with workouts | sets | exercises for a specific exercise.
  Future<List<Map>> getWorkoutsAllSpecificExerciseData(String name) async {
    Database db = await instance.database;
    List<Map> workouts = await db.rawQuery('''
      SELECT workoutID, date, exerciseId, name, sets.id as setId, weight, reps
      FROM workouts
      INNER JOIN sets
      ON workouts.id = sets.workoutId
      INNER JOIN exercises
      ON sets.exerciseId = exercises.id
      WHERE exercises.name = ?
      ORDER BY date ASC;
    ''', [name]);

    return workouts;
  }

  // Gets all workout data joined with workouts | sets | exercises for a specific exercise and workoutId.
  Future<List<Map>> getWorkoutsAllSpecificExerciseWorkoutData(
      String name, int workoutId) async {
    Database db = await instance.database;
    List<Map> workouts = await db.rawQuery('''
      SELECT workoutID, date, exerciseId, name, sets.id as setId, weight, reps
      FROM workouts
      INNER JOIN sets
      ON workouts.id = sets.workoutId
      INNER JOIN exercises
      ON sets.exerciseId = exercises.id
      WHERE exercises.name = ? AND workoutID = ?
      ORDER BY date ASC;
    ''', [name, workoutId]);

    return workouts;
  }

  // Gets all workout data joined with workouts | sets | exercises.
  Future<List<Map>> getWorkoutsAllData() async {
    Database db = await instance.database;
    List<Map> workouts = await db.rawQuery('''
      SELECT workoutID, date, exerciseId, name, sets.id as setId, weight, reps,
             bodyPart, target, equipment, image
      FROM workouts
      INNER JOIN sets
      ON workouts.id = sets.workoutId
      INNER JOIN exercises
      ON sets.exerciseId = exercises.id
    ''');

    return workouts;
  }

  // Deletes a specific workout from the workouts table using [id].
  Future<void> removeWorkout(int id) async {
    Database db = await instance.database;
    db.rawDelete('''
      DELETE FROM workouts
      WHERE id = ?
    ''', [id]);
  }

  // exercises table queries

  // Checks if an exercise exists in the exercises table.
  Future<bool> isExerciseExisting(String name) async {
    Database db = await instance.database;
    var query = await db.rawQuery('''
    SELECT * FROM exercises
    WHERE name = ? COLLATE NOCASE
    ''', [name]);

    return query.isNotEmpty ? true : false;
  }

  // Gets the exercise id for a specific exercise
  Future<List<Exercise>> getSpecificExercise(String name) async {
    Database db = await instance.database;
    var query = await db.rawQuery('''
    SELECT * FROM exercises
    WHERE name = ?
    LIMIT 1
    ''', [name]);

    List<Exercise> exerciseList = query.isNotEmpty
        ? query.map((exercise) => Exercise.fromMap(exercise)).toList()
        : [];

    return exerciseList;
  }

  // Gets a specific exercise using the [id].
  Future<List<Exercise>> getSpecificExerciseWithId(int id) async {
    Database db = await instance.database;
    var query = await db.rawQuery('''
    SELECT * FROM exercises
    WHERE id = ?
    LIMIT 1
    ''', [id]);

    List<Exercise> exerciseList = query.isNotEmpty
        ? query.map((exercise) => Exercise.fromMap(exercise)).toList()
        : [];

    return exerciseList;
  }

  // Gets all exercises from exercises table, ordered by name.
  Future<List<Exercise>> getExercises() async {
    Database db = await instance.database;
    var exercises = await db.query('exercises', orderBy: 'name');

    List<Exercise> exerciseList = exercises.isNotEmpty
        ? exercises.map((exercise) => Exercise.fromMap(exercise)).toList()
        : [];

    return exerciseList;
  }

  // Gets all favorite exercises from exercises table, ordered by name.
  Future<List<Exercise>> getFavoriteExercises() async {
    Database db = await instance.database;
    var exercises = await db.rawQuery('''
      SELECT * FROM exercises
      WHERE isFavorite = 1
    ''');

    List<Exercise> exerciseList = exercises.isNotEmpty
        ? exercises.map((exercise) => Exercise.fromMap(exercise)).toList()
        : [];

    return exerciseList;
  }

  // Update specific exercise favorite status
  Future updateFavoriteExercise(int exerciseId, bool isFavorite) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE exercises
      SET isFavorite = ?
      WHERE id = ?
    ''', [(isFavorite ? 1 : 0), exerciseId]);
  }

  Future<bool> isExerciseFavorite(int exerciseId) async {
    Database db = await instance.database;
    var exercise = await db.rawQuery('''
      SELECT * FROM exercises
      WHERE id = ?
      LIMIT 1
    ''', [exerciseId]);

    return exercise[0]['isFavorite'] == 1 ? true : false;
  }

  Future<bool> isExerciseFavoriteName(String name) async {
    Database db = await instance.database;
    var exercise = await db.rawQuery('''
      SELECT * FROM exercises
      WHERE name = ?
      LIMIT 1
    ''', [name]);

    return exercise[0]['isFavorite'] == 1 ? true : false;
  }

  // Gets all custom exercises from exercises table, ordered by name.
  Future<List<Exercise>> getCustomExercises() async {
    Database db = await instance.database;
    var exercises = await db.rawQuery('''
      SELECT * FROM exercises
      WHERE isCustom = 1
    ''');

    List<Exercise> exerciseList = exercises.isNotEmpty
        ? exercises.map((exercise) => Exercise.fromMap(exercise)).toList()
        : [];

    return exerciseList;
  }

  // Add exercise to exercises table.
  Future<int> addExercise(Exercise exerciseData) async {
    Database db = await instance.database;

    return db.insert('exercises', exerciseData.toMap());
  }

  // Edit exercise data using [id]
  Future<void> editExercise(int id, String name, String bodyPart, String target,
      String equipment) async {
    Database db = await instance.database;

    await db.rawUpdate('''
    UPDATE exercises
    SET name = ?, bodyPart = ?, target = ?, equipment = ?
    WHERE id = ?
    ''', [name, bodyPart, target, equipment, id]);
  }

  // Delete exercise from exercises table using [id].
  Future<void> removeExercise(int id) async {
    Database db = await instance.database;
    db.rawDelete('''
    DELETE FROM exercises
    WHERE id = ?
    ''', [id]);
  }

  // sets table queries

  // Insert new [setData] into sets table.
  Future<int> addSet(SetData setData) async {
    Database db = await instance.database;

    return await db.insert('sets', setData.toMap());
  }

  // Gets all sets from sets table.
  Future<List<SetData>> getSets() async {
    Database db = await instance.database;
    var sets = await db.query('sets');

    List<SetData> setsList =
        sets.isNotEmpty ? sets.map((set) => SetData.fromMap(set)).toList() : [];

    return setsList;
  }

  // Gets specific sets from sets table using [date].
  Future<List<SetData>> getSpecificWorkoutSets(int workoutId) async {
    Database db = await instance.database;
    var sets = await db.rawQuery('''
      SELECT * FROM sets
      WHERE workoutId = ?
    ''', [workoutId]);

    List<SetData> setsList =
        sets.isNotEmpty ? sets.map((set) => SetData.fromMap(set)).toList() : [];

    return setsList;
  }

  // Deletes specific set from sets table using the set [id].
  Future<int> removeSet(int id) async {
    Database db = await instance.database;
    return await db.delete('sets', where: 'id = ?', whereArgs: [id]);
  }

  // Update specific set
  Future updateSet(
      int setId, String weight, String reps, String timestamp) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE sets
      SET weight = ?, reps = ?, timestamp = ?
      WHERE id = ?
    ''', [weight, reps, timestamp, setId]);
  }

  // reminders table queries

  // Insert new [reminderData] into reminders table.
  Future<int> addReminder(Reminder reminderData) async {
    Database db = await instance.database;

    return await db.insert('reminders', reminderData.toMap());
  }

  // Gets all reminder data from reminders table.
  Future<List<Reminder>> getReminders() async {
    Database db = await instance.database;
    var reminders = await db.query('reminders', orderBy: 'id');

    List<Reminder> reminderList = reminders.isNotEmpty
        ? reminders.map((reminder) => Reminder.fromMap(reminder)).toList()
        : [];

    return reminderList;
  }

  // Gets specific reminder data from reminders table.
  Future<List<Reminder>> getSpecificReminder(int reminderId) async {
    Database db = await instance.database;
    var reminders =
        await db.query('reminders', where: 'id = ?', whereArgs: [reminderId]);

    List<Reminder> reminderList = reminders.isNotEmpty
        ? reminders.map((reminder) => Reminder.fromMap(reminder)).toList()
        : [];

    return reminderList;
  }

  // Update the status of isOn in the reminders table for specific id.
  Future<void> updateReminderIsOn(int reminderId, int isReminderOn) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE reminders
      SET isOn = ?
      WHERE id = ?
    ''', [isReminderOn, reminderId]);
  }

  // Edit a specific reminder using the id.
  Future<void> editReminder(
      String time,
      int monday,
      int tuesday,
      int wednesday,
      int thursday,
      int friday,
      int saturday,
      int sunday,
      String? notes,
      int reminderId) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE reminders
      SET time = ?, monday = ?, tuesday = ?, wednesday = ?, thursday = ?, friday = ?, saturday = ?, sunday = ?, notes = ?
      WHERE id = ?
    ''', [
      time,
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday,
      sunday,
      notes,
      reminderId
    ]);
  }

  // routines table

  // Verify if routine exists
  Future<bool> isRoutineExisting(String name) async {
    Database db = await instance.database;

    var query = await db.rawQuery('''
      SELECT * FROM routines
      WHERE name = ?
      
    ''', [name]);

    return query.isNotEmpty ? true : false;
  }

  // Gets first matching Routine from routines table.
  // Uses [name] to query.
  Future<List<Routine>> getRoutine(String name) async {
    Database db = await instance.database;

    var query = await db.rawQuery('''
      SELECT * FROM routines
      WHERE name = ?
      limit 1
    ''', [name]);

    List<Routine> routineList = query.isNotEmpty
        ? query.map((routine) => Routine.fromMap(routine)).toList()
        : [];

    return routineList;
  }

  // Gets all routines from routines table.
  Future<List<Routine>> getRoutines() async {
    Database db = await instance.database;
    var routines = await db.query('routines', orderBy: 'id');

    List<Routine> routinesList = routines.isNotEmpty
        ? routines.map((routine) => Routine.fromMap(routine)).toList()
        : [];

    return routinesList;
  }

  // Insert routine into routines table
  Future<int> addRoutine(Routine routineData) async {
    Database db = await instance.database;

    return await db.insert('routines', routineData.toMap());
  }

  // Update specific routine name
  Future updateSpecificRoutineName(int id, String name) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE routines
      SET name = ?
      WHERE id = ?
    ''', [name, id]);
  }

  // Update specific routine difficulty
  Future updateSpecificRoutineDifficulty(int id, int difficulty) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE routines
      SET difficulty = ?
      WHERE id = ?
    ''', [difficulty, id]);
  }

  // Deletes specific routine from routines table using the [id].
  Future<int> removeRoutine(int id) async {
    Database db = await instance.database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // routineSets table

  // Insert [routineExerciseData] into routineExercises table
  Future<int> addRoutineSet(RoutineSet routineSetData) async {
    Database db = await instance.database;

    return await db.insert('routineSets', routineSetData.toMap());
  }

  // Gets specific RoutineSet data from routineSets table.
  Future<List<RoutineSet>> getSpecificRoutineSets(int id) async {
    Database db = await instance.database;
    var routineSets =
        await db.query('routineSets', where: 'routineId = ?', whereArgs: [id]);

    List<RoutineSet> routineSetsList = routineSets.isNotEmpty
        ? routineSets
            .map((routineSet) => RoutineSet.fromMap(routineSet))
            .toList()
        : [];

    return routineSetsList;
  }

  // Deletes a specific RoutineSet from routineSets table using [id].
  Future<int> removeSpecificRoutineSet(int id) async {
    Database db = await instance.database;
    return await db.delete('routineSets', where: 'id = ?', whereArgs: [id]);
  }

  // Deletes specific RoutineSets from routineSets table using [name].
  Future<int> removeSpecificRoutineSets(String name) async {
    Database db = await instance.database;
    return await db.delete('routineSets', where: 'name = ?', whereArgs: [name]);
  }

  // Update specific routineSet
  Future updateRoutineSet(int id, String weight, String reps) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE routineSets
      SET weight = ?, reps = ?
      WHERE id = ?
    ''', [weight, reps, id]);
  }

  // Deletes specific reminder from reminders table using the reminder [id].
  Future<int> removeReminder(int id) async {
    Database db = await instance.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // workoutNotes table

  // Gets first matching workoutNote from workoutNotes table.
  Future<List<Note>> getWorkoutNote(int workoutId) async {
    Database db = await instance.database;

    var query = await db.rawQuery('''
      SELECT * FROM workoutNotes
      WHERE workoutId = ?
      limit 1
    ''', [workoutId]);

    List<Note> noteList = query.isNotEmpty
        ? query.map((note) => Note.fromMap(note)).toList()
        : [];

    return noteList;
  }

  // Insert new workoutNote into workoutNotes table.
  Future<int> addNote(Note workoutNote) async {
    Database db = await instance.database;

    return await db.insert('workoutNotes', workoutNote.toMap());
  }

  // Update specific note
  Future updateWorkoutNote(int workoutId, String note, String timestamp) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE workoutNotes
      SET note = ?, timestamp = ?
      WHERE workoutId = ?
    ''', [note, timestamp, workoutId]);
  }

  // Deletes the workoutApp.db
  Future<void> deleteDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'workoutApp.db');
    databaseFactory.deleteDatabase(path);
    print('deleted database');
  }
}
