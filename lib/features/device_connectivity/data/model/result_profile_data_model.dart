// features/device_connectivity/data/model/result_profile_data_model.dart
import 'dart:typed_data';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';

class ResultProfileDataModel {
  final Uint8List? profileImage;
  final String name;
  final String email;
  final String gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? dietitianId;
  final String dietitianName;
  final String phoneNo;

  const ResultProfileDataModel({
    this.profileImage,
    required this.name,
    required this.email,
    required this.gender,
    this.age,
    this.height,
    this.weight,
    this.dietitianId,
    required this.dietitianName,
    required this.phoneNo,
  });

  /// Factory bridge from ProfileState
  factory ResultProfileDataModel.fromProfileState(ProfileState state) {
    return ResultProfileDataModel(
      profileImage: state.profileImage,
      name: state.name,
      email: state.email,
      gender: state.gender,
      age: state.age,
      height: state.height,
      weight: state.weight,
      dietitianId: state.dietitianId,
      dietitianName: state.dietitianName,
      phoneNo: state.phoneNo,
    );
  }
}
