class ActivityModel {
  final String id;
  final String userId;
  final String type;
  final int durationMin;
  final String intensity;
  final String dateISO;
  final String? note;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.dateISO,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'durationMin': durationMin,
        'intensity': intensity,
        'dateISO': dateISO,
        'note': note,
      };

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id: json['id'],
        userId: json['userId'],
        type: json['type'],
        durationMin: json['durationMin'],
        intensity: json['intensity'],
        dateISO: json['dateISO'],
        note: json['note'],
      );
}