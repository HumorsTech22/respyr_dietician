import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/weight_unit.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/core/utils/validators.dart'; // Your separate validators file

class ProfileCubit extends Cubit<ProfileState> {
  final CalculateBMI calculateBMI;
  final CalculateBMR calculateBMR;
  final DietitianRepository dietitianRepository;

  ProfileCubit(this.calculateBMI, this.calculateBMR, this.dietitianRepository)
    : super(const ProfileState());

  void updateProfileImage(Uint8List imageData) {
    emit(state.copyWith(profileImage: imageData));
  }

  void updateName(String name) => emit(state.copyWith(name: name));

  void updateEmail(String email) => emit(state.copyWith(email: email));

  void updateLocation(String location) =>
      emit(state.copyWith(location: location));

  void updateGender(String gender) => emit(state.copyWith(gender: gender));

  void updateAge(int age) => emit(state.copyWith(age: age));

  void updateHeight(double heightCm) => emit(state.copyWith(height: heightCm));
  void updatedietitian(String deiticianId) =>
      emit(state.copyWith(dietitianId: deiticianId));

  void updateHeightFromFeet(int feet, int inches) {
    final cm = (feet * 30.48) + (inches * 2.54);
    emit(state.copyWith(height: cm));
  }

  void updateHeightUnit(HeightUnit unit) {
    emit(state.copyWith(heightUnit: unit));
  }

  void updateWeight(double weightKg) => emit(state.copyWith(weight: weightKg));

  void updateWeightFromLbs(double lbs) {
    final kg = lbs * 0.453592;
    emit(state.copyWith(weight: kg));
  }

  void updateWeightUnit(WeightUnit unit) {
    emit(state.copyWith(weightUnit: unit));
  }

  // These delegate to utils/validators.dart for cleanliness and reuse
  String? validateAgeInput(String input) => Validators.validateAge(input);

  String? validateWeightInput(String input, WeightUnit unit) =>
      Validators.validateWeight(input, unit);

  String? validateHeightInput(String input, HeightUnit unit) =>
      Validators.validateHeight(input, unit);

  Future<void> fetchdietitianName(String id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final dietitian = await dietitianRepository.fetchDietitian(id);

      if (dietitian != null) {
        emit(
          state.copyWith(
            dietitianId: dietitian.dietitianId,
            dietitianName: dietitian.name,
            email: dietitian.email,
            location: dietitian.location,
            dietitianImageUrl: dietitian.logoUrl,
            phoneNo: dietitian.phoneNo,
            isLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(dietitianName: "NotFound", isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(dietitianName: "Error", isLoading: false));
    }

    // await Future.delayed(Duration(seconds: 1));

    // if (id == "RespyrD01") {
    //   emit(state.copyWith(dietitianId: id, dietitianName: "CLINICALRESPYR101"));
    // } else {
    //   emit(state.copyWith(dietitianId: null, dietitianName: "NotFound"));
    // }
  }

  void cleardietitianName() {
    emit(state.copyWith(dietitianName: ""));
  }

  double? getBMI() {
    if (state.height != null && state.weight != null) {
      return calculateBMI(state.weight!, state.height!);
    }
    return null;
  }

  double? getBMR() {
    if (state.height != null && state.weight != null && state.age != null) {
      return calculateBMR(
        weightKg: state.weight!,
        heightCm: state.height!,
        age: state.age!,
        gender: state.gender,
      );
    }
    return null;
  }
}
