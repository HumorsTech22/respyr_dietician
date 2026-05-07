class UserHabitsModel {
  final int id;
  final String profileId;
  final String goal;
  final String activity;
  final FoodTypeModel foodType;
  final String dateTime;
  final String timeStamp;

  UserHabitsModel({
    required this.id,
    required this.profileId,
    required this.goal,
    required this.activity,
    required this.foodType,
    required this.dateTime,
    required this.timeStamp,
  });

  factory UserHabitsModel.fromJson(Map<String, dynamic> json) {
    return UserHabitsModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      profileId: json['profile_id']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      foodType: FoodTypeModel.fromJson(
        json['food_type'] is Map<String, dynamic>
            ? json['food_type']
            : {},
      ),
      dateTime: json['dttm']?.toString() ?? '',
      timeStamp: json['tsstamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'goal': goal,
      'activity': activity,
      'food_type': foodType.toJson(),
      'dttm': dateTime,
      'tsstamp': timeStamp,
    };
  }

  UserHabitsModel copyWith({
    int? id,
    String? profileId,
    String? goal,
    String? activity,
    FoodTypeModel? foodType,
    String? dateTime,
    String? timeStamp,
  }) {
    return UserHabitsModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      goal: goal ?? this.goal,
      activity: activity ?? this.activity,
      foodType: foodType ?? this.foodType,
      dateTime: dateTime ?? this.dateTime,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }
}

class FoodTypeModel {
  final String dietType;
  final String primaryCuisine;
  final String secondaryCuisine;

  FoodTypeModel({
    required this.dietType,
    required this.primaryCuisine,
    required this.secondaryCuisine,
  });

  factory FoodTypeModel.fromJson(Map<String, dynamic> json) {
    return FoodTypeModel(
      dietType: json['diet_type']?.toString() ?? '',
      primaryCuisine: json['primary_cuisine']?.toString() ?? '',
      secondaryCuisine: json['secondary_cuisine']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diet_type': dietType,
      'primary_cuisine': primaryCuisine,
      'secondary_cuisine': secondaryCuisine,
    };
  }

  FoodTypeModel copyWith({
    String? dietType,
    String? primaryCuisine,
    String? secondaryCuisine,
  }) {
    return FoodTypeModel(
      dietType: dietType ?? this.dietType,
      primaryCuisine: primaryCuisine ?? this.primaryCuisine,
      secondaryCuisine: secondaryCuisine ?? this.secondaryCuisine,
    );
  }
}