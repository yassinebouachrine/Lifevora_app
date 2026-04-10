class ActivityModel {
  final String id;
  final String userId;
  final String type;
  final int durationMin;
  final String intensity;
  final String dateISO;
  final String? note;
  final int? caloriesBurned;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.dateISO,
    this.note,
    this.caloriesBurned,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'durationMin': durationMin,
        'intensity': intensity,
        'dateISO': dateISO,
        'note': note,
        'caloriesBurned': caloriesBurned,
      };

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        durationMin: json['durationMin'] is int
            ? json['durationMin']
            : int.tryParse(json['durationMin'].toString()) ?? 0,
        intensity: json['intensity']?.toString() ?? 'modere',
        dateISO: json['dateISO']?.toString() ?? '',
        note: json['note']?.toString(),
        caloriesBurned: json['caloriesBurned'] is int
            ? json['caloriesBurned']
            : int.tryParse(json['caloriesBurned']?.toString() ?? ''),
      );

  ActivityModel copyWith({
    String? id,
    String? userId,
    String? type,
    int? durationMin,
    String? intensity,
    String? dateISO,
    String? note,
    int? caloriesBurned,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      durationMin: durationMin ?? this.durationMin,
      intensity: intensity ?? this.intensity,
      dateISO: dateISO ?? this.dateISO,
      note: note ?? this.note,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}