import 'package:equatable/equatable.dart';

abstract class OtgState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtgInitial extends OtgState {}

class OtgLoading extends OtgState {}

class OtgOpenedSettings extends OtgState {}

class OtgError extends OtgState {
  final String message;
  OtgError(this.message);

  @override
  List<Object?> get props => [message];
}
