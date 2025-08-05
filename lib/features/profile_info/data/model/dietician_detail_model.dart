class DieticianDetailModel {
  final String id;
  final String dieticianId;
  final String name;
  final String phoneNo;
  final String email;
  final String location;
  final String logoUrl;

  DieticianDetailModel({
    required this.id,
    required this.dieticianId,
    required this.name,
    required this.phoneNo,
    required this.email,
    required this.location,
    required this.logoUrl,
  });

  factory DieticianDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DieticianDetailModel(
      id: data['id'].toString(),
      dieticianId: data['dietician_id'],
      name: data['name'],
      phoneNo: data['phone_no'],
      email: data['email'],
      location: data['location'],
      logoUrl: data['logo_url'],
    );
  }
}
