import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/weight_unit.dart';

class ProfileState extends Equatable {
  final Uint8List? profileImage;
  final String name;
  final String email;
  final String location;
  final String gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? dieticianId;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final String dieticianName;
  final String dieticianImageUrl;
  final String phoneNo;
  final bool? isLoading;

  const ProfileState({
    this.profileImage,
    this.name = '',
    this.email = '',
    this.location = '',
    this.gender = 'Female',
    this.age,
    this.height,
    this.weight,
    this.dieticianId,
    this.heightUnit = HeightUnit.cm,
    this.weightUnit = WeightUnit.kg,
    this.dieticianName = '',
    this.dieticianImageUrl = '',
    this.phoneNo = '',
    this.isLoading,
  });

  ProfileState copyWith({
    Uint8List? profileImage,
    String? name,
    String? email,
    String? location,
    String? gender,
    int? age,
    double? height,
    double? weight,
    HeightUnit? heightUnit,
    WeightUnit? weightUnit,
    String? dieticianId,
    String? dieticianName,
    String? dieticianImageUrl,
    String? phoneNo,
    bool? isLoading,
  }) {
    return ProfileState(
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      heightUnit: heightUnit ?? this.heightUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      dieticianId: dieticianId ?? this.dieticianId,
      dieticianName: dieticianName ?? this.dieticianName,
      dieticianImageUrl: dieticianImageUrl ?? this.dieticianImageUrl,
      phoneNo: phoneNo ?? this.phoneNo,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    profileImage,
    name,
    email,
    location,
    gender,
    age,
    height,
    weight,
    heightUnit,
    weightUnit,
    dieticianId,
    dieticianName,
    dieticianImageUrl,
    phoneNo,
    isLoading,
  ];

  @override
  String toString() =>
      'ProfileState(profileImage: $profileImage, name: $name, email: $email, location: $location, gender: $gender, age: $age, height: $height, weight: $weight, heightUnit: $heightUnit, weightUnit: $weightUnit, dieticianId: $dieticianId)';
}
