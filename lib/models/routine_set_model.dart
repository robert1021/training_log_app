class RoutineSet {
  final int? id;
  final int routineId;
  final int exerciseId;
  final String name;
  final String weight;
  final String reps;

  RoutineSet({
    this.id,
    required this.routineId,
    required this.exerciseId,
    required this.name,
    required this.weight,
    required this.reps,
  });

  factory RoutineSet.fromMap(Map<String, dynamic> json) =>
      RoutineSet(
        id: json['id'],
        routineId: json['routineId'],
        exerciseId: json['exerciseId'],
        name: json['name'],
        weight: json['weight'],
        reps: json['reps'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'exerciseId': exerciseId,
      'name': name,
      'weight': weight,
      'reps': reps,
    };
  }
}
