class ClientProfileModel {
  final int id;
  final String dieticianId;
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

  ClientProfileModel({
    required this.id,
    required this.dieticianId,
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
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id'],
      dieticianId: json['dietician_id'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dietician_id': dieticianId,
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
    };
  }
}
