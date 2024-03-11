class Note {
  final int? id;
  final int workoutId;
  final String note;
  final String timestamp;

  Note(
      {this.id,
      required this.workoutId,
      required this.note,
      required this.timestamp});

  factory Note.fromMap(Map<String, dynamic> json) => Note(
      id: json['id'],
      workoutId: json['workoutId'],
      note: json['note'],
      timestamp: json['timestamp']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'note': note,
      'timestamp': timestamp
    };
  }
}
