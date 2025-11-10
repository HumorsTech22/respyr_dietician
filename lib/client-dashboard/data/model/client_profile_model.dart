class ClientProfileModel {
  final int id;
  final String dietitianId;
  final String profileId;
  final String phoneNo;
  final String email;
  final String profileName;
  final String profileImage;
  final String age;
  final String gender;
  final String height;
  final String weight;
  final String region;
  final String location;
  final String dttm;
  final int isNotificationEnabled;

  ClientProfileModel({
    required this.id,
    required this.dietitianId,
    required this.profileId,
    required this.phoneNo,
    required this.email,
    required this.profileName,
    required this.profileImage,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.region,
    required this.location,
    required this.dttm,
    required this.isNotificationEnabled,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id'],
      dietitianId: json['dietician_id'],
      profileId: json['profile_id'],
      phoneNo: json['phone_no'],
      email: json['email'],
      profileName: json['profile_name'],
      profileImage: json['profile_image'],
      age: json['age'],
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      region: json['region'],
      location: json['location'],
      dttm: json['dttm'],
      isNotificationEnabled: json['is_notification_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dietician_id': dietitianId,
      'profile_id': profileId,
      'phone_no': phoneNo,
      'email': email,
      'profile_name': profileName,
      'profile_image': profileImage,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'region': region,
      'location': location,
      'dttm': dttm,
      'is_notification_enabled': isNotificationEnabled,
    };
  }

  // Add copyWith method for immutability
  ClientProfileModel copyWith({
    int? id,
    String? dietitianId,
    String? profileId,
    String? phoneNo,
    String? email,
    String? profileName,
    String? profileImage,
    String? age,
    String? gender,
    String? height,
    String? weight,
    String? region,
    String? location,
    String? dttm,
    int? isNotificationEnabled,
  }) {
    return ClientProfileModel(
      id: id ?? this.id,
      dietitianId: dietitianId ?? this.dietitianId,
      profileId: profileId ?? this.profileId,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      profileName: profileName ?? this.profileName,
      profileImage: profileImage ?? this.profileImage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      region: region ?? this.region,
      location: location ?? this.location,
      dttm: dttm ?? this.dttm,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }

  // Helper method to convert to boolean for easier UI handling
  bool get isNotificationsEnabledBool => isNotificationEnabled == 1;

  // Helper method to convert from boolean to int for API
  static int boolToInt(bool value) => value ? 1 : 0;
}