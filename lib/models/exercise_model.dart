class Exercise {
  final int? id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String? image;
  final int? isFavorite;
  final int? isCustom;

  Exercise({
    this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    this.image,
    this.isFavorite,
    this.isCustom,
  });

  factory Exercise.fromMap(Map<String, dynamic> json) => Exercise(
      id: json['id'],
      name: json['name'],
      bodyPart: json['bodyPart'],
      target: json['target'],
      equipment: json['equipment'],
      image: json['image'],
      isFavorite: json['isFavorite'],
      isCustom: json['isCustom']
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'target': target,
      'equipment': equipment,
      'image': image,
      'isFavorite': isFavorite,
      'isCustom' : isCustom,
    };

  }


}
