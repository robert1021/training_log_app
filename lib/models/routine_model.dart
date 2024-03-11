class Routine {
  final int? id;
  final String name;
  final int difficulty;
  final String timestamp;

  Routine({
    this.id,
    required this.name,
    required this.difficulty,
    required this.timestamp,
  });

  factory Routine.fromMap(Map<String, dynamic> json) => Routine(
        id: json['id'],
        name: json['name'],
        difficulty: json['difficulty'],
        timestamp: json['timestamp'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'timestamp': timestamp,
    };
  }
}
