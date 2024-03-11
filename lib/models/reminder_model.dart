class Reminder {
  final int? id;
  final int isOn;
  final String time;
  final int monday;
  final int tuesday;
  final int wednesday;
  final int thursday;
  final int friday;
  final int saturday;
  final int sunday;
  final String? notes;

  Reminder({
    this.id,
    required this.isOn,
    required this.time,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    this.notes,
  });

  factory Reminder.fromMap(Map<String, dynamic> json) => Reminder(
      id: json['id'],
      isOn: json['isOn'],
      time: json['time'],
      monday: json['monday'],
      tuesday: json['tuesday'],
      wednesday: json['wednesday'],
      thursday: json['thursday'],
      friday: json['friday'],
      saturday: json['saturday'],
      sunday: json['sunday'],
      notes: json['notes'],
  );


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isOn': isOn,
      'time': time,
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
      'notes': notes,
    };
  }
}
