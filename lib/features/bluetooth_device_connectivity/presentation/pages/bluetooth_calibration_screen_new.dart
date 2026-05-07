import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BluetoothCalibrationScreenNew extends StatefulWidget {
  const BluetoothCalibrationScreenNew({super.key});

  @override
  State<BluetoothCalibrationScreenNew> createState() =>
      _BluetoothCalibrationScreenNewState();
}

class _BluetoothCalibrationScreenNewState
    extends State<BluetoothCalibrationScreenNew> {
  late VideoPlayerController _controller;
  bool _isVideoCompleted = false;
  int _currentVideoIndex = 0;

  List<String> _videoPaths = [
    'assets/images/device_connection/cal_0.mp4', // First video
    'assets/images/device_connection/cal_1.mp4', // Second video (Loop for 90 seconds)
    'assets/images/device_connection/cal_3.mp4', // Third video
  ];

  @override
  void initState() {
    super.initState();
    _playNextVideo();
  }

  void _playNextVideo() {
    if (_currentVideoIndex < _videoPaths.length) {
      _controller = VideoPlayerController.asset(_videoPaths[_currentVideoIndex])
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
          _controller.setVolume(0); // Mute the video
          print("Playing video: ${_videoPaths[_currentVideoIndex]}");

          if (_currentVideoIndex == 0) {
            // First video: Play once, then move to the second
            _controller.addListener(() {
              if (_controller.value.position == _controller.value.duration &&
                  !_isVideoCompleted) {
                print("First video completed");
                setState(() {
                  _isVideoCompleted = true;
                  _currentVideoIndex++;
                });
                _controller.pause();
                _playNextVideo();
              }
            });
          } else if (_currentVideoIndex == 1) {
            // Second video: Loop for 90 seconds
            print("Starting 90-second loop for second video");
            Future.delayed(Duration(seconds: 10), () {
              if (_currentVideoIndex == 1) {
                print("90 seconds completed, moving to the third video.");
                setState(() {
                  _currentVideoIndex++;
                });
                _controller.pause();
                _playNextVideo();
              }
            });
          } else if (_currentVideoIndex == 2) {
            // Third video: Play once after second video
            _controller.addListener(() {
              if (_controller.value.position == _controller.value.duration &&
                  !_isVideoCompleted) {
                print("Third video completed");
                setState(() {
                  _isVideoCompleted = true;
                });
              }
            });
          }
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    print("Video controller disposed");
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      print("Video is still loading...");
      return const Center(child: CircularProgressIndicator());
    }

    print("Video is initialized and ready to play");

    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Calibration")),
      body: SafeArea(
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}