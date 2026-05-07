class CoachProfileModel {
  final int id;
  final String dietitianId;
  final String name;
  final String phoneNo;
  final String email;
  final String location;
  final String dttm;
  final int isResetPassword;

  CoachProfileModel({
    required this.id,
    required this.dietitianId,
    required this.name,
    required this.phoneNo,
    required this.email,
    required this.location,
    required this.dttm,
    required this.isResetPassword,
  });

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    return CoachProfileModel(
      id: (json["id"] ?? 0) is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      dietitianId: "${json["dietician_id"] ?? ""}",
      name: "${json["name"] ?? ""}",
      phoneNo: "${json["phone_no"] ?? ""}",
      email: "${json["email"] ?? ""}",
      location: "${json["location"] ?? ""}",
      dttm: "${json["dttm"] ?? ""}",
      isResetPassword: (json["is_reset_password"] ?? 0) is int
          ? json["is_reset_password"]
          : int.tryParse("${json["is_reset_password"]}") ?? 0,
    );
  }
}