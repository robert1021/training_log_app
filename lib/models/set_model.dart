class SetData {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final String weight;
  final String reps;
  final String timestamp;

  SetData({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.timestamp,
  });

  factory SetData.fromMap(Map<String, dynamic> json) => SetData(
      id: json['id'],
      workoutId: json['workoutId'],
      exerciseId: json['exerciseId'],
      weight: json['weight'],
      reps: json['reps'],
      timestamp: json['timestamp'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'timestamp': timestamp,
    };

  }

}
