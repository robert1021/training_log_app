class WorkoutData {
  final int? id;
  final String date;
  final String timestamp;


  WorkoutData({
    this.id,
    required this.date,
    required this.timestamp,
  });

  factory WorkoutData.fromMap(Map<String, dynamic> json) => WorkoutData(
      id: json['id'],
      date: json['date'],
      timestamp: json['timestamp'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'timestamp': timestamp,
    };

  }

}
