class Car {
  final String id;
  String name;
  String color;
  String note;
  bool isAvailable;

  static const double pricePerSession = 20000;

  Car({
    required this.id,
    required this.name,
    required this.color,
    this.note = '',
    this.isAvailable = true,
  });

  Car copyWith({
    String? name,
    String? color,
    String? note,
    bool? isAvailable,
  }) {
    return Car(
      id:          id,
      name:        name ?? this.name,
      color:       color ?? this.color,
      note:        note ?? this.note,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id:          json['id'] as String,
      name:        json['name'] as String,
      color:       json['color'] as String,
      note:        (json['note'] as String?) ?? '',
      isAvailable: (json['is_available'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':         name,
      'color':        color,
      'note':         note,
      'is_available': isAvailable,
    };
  }
}