import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/issue_with_connection/issue_with_connection_state.dart';

class OtgCubit extends Cubit<OtgState> {
  final OpenSettingsUseCase openSettingsUseCase;

  OtgCubit(this.openSettingsUseCase) : super(OtgInitial());

  Future<void> openSettings() async {
    emit(OtgLoading());
    try {
      await openSettingsUseCase.execute();
      emit(OtgOpenedSettings());
    } catch (e) {
      emit(OtgError(e.toString()));
    }
  }
}

class OtgRepository {
  Future<void> openSettings() async {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message: 'Platform not supported',
      );
    }

    final intent = AndroidIntent(action: 'android.settings.SETTINGS');
    await intent.launch();
  }
}

class OpenSettingsUseCase {
  final OtgRepository repository;

  OpenSettingsUseCase(this.repository);

  Future<void> execute() async {
    await repository.openSettings();
  }
}
