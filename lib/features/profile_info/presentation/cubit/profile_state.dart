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
  final int? dieticianId;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final bool isCheckboxChecked;
  final String dieticianName;
  final String dieticianImageUrl;

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
    this.isCheckboxChecked = false,
    this.dieticianName = '',
    this.dieticianImageUrl = '',
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
    int? dieticianId,
    bool? isCheckboxChecked,
    String? dieticianName,
    String? dieticianImageUrl,
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
      isCheckboxChecked: isCheckboxChecked ?? this.isCheckboxChecked,
      dieticianName: dieticianName ?? this.dieticianName,
      dieticianImageUrl: dieticianImageUrl ?? this.dieticianImageUrl,
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
    isCheckboxChecked,
    dieticianName,
    dieticianImageUrl,
  ];

  @override
  String toString() =>
      'ProfileState(profileImage: $profileImage, name: $name, email: $email, location: $location, gender: $gender, age: $age, height: $height, weight: $weight, heightUnit: $heightUnit, weightUnit: $weightUnit, dieticianId: $dieticianId, isCheckboxChecked: $isCheckboxChecked)';
}
