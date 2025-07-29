import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/weight_unit.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietician/core/utils/validators.dart'; // Your separate validators file

class ProfileCubit extends Cubit<ProfileState> {
  final CalculateBMI calculateBMI;
  final CalculateBMR calculateBMR;

  ProfileCubit(this.calculateBMI, this.calculateBMR)
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
  void updateDietician(int deiticianId) =>
      emit(state.copyWith(dieticianId: deiticianId));

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

  void toggleCheckbox(bool value) {
    emit(state.copyWith(isCheckboxChecked: value));
  }

  Future<void> fetchDieticianName(String id) async {
    emit(state.copyWith(dieticianName: ""));

    await Future.delayed(Duration(seconds: 1));

    if (id == "123456789") {
      emit(
        state.copyWith(
          dieticianId: int.tryParse(id),
          dieticianName: "CLINICALRESPYR101",
        ),
      );
    } else {
      emit(state.copyWith(dieticianId: null, dieticianName: "NotFound"));
    }
  }

  void clearDieticianName() {
    emit(state.copyWith(dieticianName: ""));
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
