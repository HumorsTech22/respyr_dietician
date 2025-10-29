import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/processor/usb_blow_processor.dart';
import 'package:respyr_dietitian/common/widgets/threshold.dart';
import 'exhale_state.dart';

class ExhaleCubit extends Cubit<ExhaleState> {
  final UsbBlowProcessor processor;
  final UsbCommunicationService usbService;
  final String baseValue;

  Timer? _countdownTimer;
  StreamSubscription<String>? _usbSubscription;
  int _seconds = 30;
  bool _isConnected = false;

  ExhaleCubit({
    required this.processor,
    required this.usbService,
    required this.baseValue,
  }) : super(ExhaleInitial()) {
    _init();
  }

  void _init() {
    processor.reset();
    processor.processBlowData(
      baseValue,
      (val) => Thresholds.calculateThresholdPercentage(val),
      (base, curr) => Thresholds.calculateBlowPercentage(base, curr),
    );
    _isConnected = usbService.isConnected;

    _usbSubscription = usbService.dataStream.listen(_onUsbData);

    _startCountdown();

    emit(_buildProgressState());
  }

  void _onUsbData(String data) {
    processor.processBlowData(
      data,
      (val) => Thresholds.calculateThresholdPercentage(val),
      (base, curr) => Thresholds.calculateBlowPercentage(base, curr),
    );

    if (processor.isBlown) {
      _countdownTimer?.cancel();
    }
    if (processor.isAbort) {
      if (processor.isImproperBlow) {
        usbService.sendData("&");
        emit(ExhaleImproper("Improper Exhale – Please try again!"));
      } else if (processor.isBlowComplete) {
        usbService.sendData("/");
        processor.moveToResults = true;
        emit(ExhaleDone());
      }

      _usbSubscription?.cancel();
      _countdownTimer?.cancel();
      return;
    }

    emit(_buildProgressState());
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _seconds = 30;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        emit(_buildProgressState());
      } else {
        emit(ExhaleError("Session Timed Out!"));
        timer.cancel();
      }
    });
  }

  ExhaleInProgress _buildProgressState() {
    double? threshold = processor.thresholdPercentage;
    double progress = (processor.blowP ?? 0.0) / 100.0;
    String info = _getInfo(progress, threshold);
    return ExhaleInProgress(
      progress: progress,
      secondsRemaining: _seconds,
      isConnected: _isConnected,
      thresholdPercentage: threshold,
      infoText: info,
    );
  }

  String _getInfo(double progress, double? thresholdPercentage) {
    if (thresholdPercentage == null) return 'Start Exhaling...';
    double threshold = thresholdPercentage / 120;
    if (progress >= 0.0 && progress < 0.10 && progress < threshold) {
      return 'Start Exhaling...';
    }
    if (progress >= 0.10 && progress < threshold) return 'Exhale Harder';
    return 'Keep Exhaling';
  }

  void restart() {
    _usbSubscription?.cancel();
    _countdownTimer?.cancel();
    _init();
  }

  @override
  Future<void> close() {
    _usbSubscription?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
