class UserModel {
  final String id;
  final String name;
  final int age;
  final int goalMinutesPerWeek;
  final String? email;
  final String? avatarState;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.goalMinutesPerWeek,
    this.email,
    this.avatarState = 'neutral',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'goalMinutesPerWeek': goalMinutesPerWeek,
        'email': email,
        'avatarState': avatarState,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 25,
        goalMinutesPerWeek: json['goalMinutesPerWeek'] is int
            ? json['goalMinutesPerWeek']
            : int.tryParse(json['goalMinutesPerWeek'].toString()) ?? 150,
        email: json['email']?.toString(),
        avatarState: json['avatarState']?.toString() ?? 'neutral',
      );

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    int? goalMinutesPerWeek,
    String? email,
    String? avatarState,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      goalMinutesPerWeek: goalMinutesPerWeek ?? this.goalMinutesPerWeek,
      email: email ?? this.email,
      avatarState: avatarState ?? this.avatarState,
    );
  }
}