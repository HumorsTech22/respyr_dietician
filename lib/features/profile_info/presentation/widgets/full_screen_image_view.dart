import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  final Uint8List imageData;

  const FullScreenImageView({super.key, required this.imageData});

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView>
    with SingleTickerProviderStateMixin {
  double _verticalOffset = 0.0;
  double _opacity = 1.0;
  bool _isDragging = false;

  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animationReset;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animationController.addListener(() {
      _transformationController.value = _animationReset!.value;
    });

    // Optional: store image globally
    SharedImageData.base64Image = base64Encode(widget.imageData);
  }

  void _handleDoubleTap() {
    final Matrix4 end =
        _zoomed ? Matrix4.identity() : Matrix4.identity()
          ..scale(1.2); // zoom in scale

    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: end,
    ).animate(
      CurveTween(curve: Curves.easeInOut).animate(_animationController),
    );

    _animationController.forward(from: 0);
    _zoomed = !_zoomed;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Important
      body: GestureDetector(
        onVerticalDragStart: (_) {
          setState(() => _isDragging = true);
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _verticalOffset += details.delta.dy;
            _opacity = (1 - (_verticalOffset.abs() / 300)).clamp(0.0, 1.0);
          });
        },
        onDoubleTap: _handleDoubleTap,
        onVerticalDragEnd: (details) {
          if (_verticalOffset.abs() > 120) {
            Navigator.of(context).pop(); // Trigger dismiss
          } else {
            // Animate back to center
            setState(() {
              _verticalOffset = 0;
              _opacity = 1.0;
              _isDragging = false;
            });
          }
        },
        child: Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _opacity,
              child: Container(
                color: Colors.black.withAlpha((_opacity * 255).toInt()),
              ), // fade to reveal previous screen
            ),
            AnimatedPositioned(
              duration:
                  _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
              top: _verticalOffset,
              left: 0,
              right: 0,
              bottom: -_verticalOffset,
              child: Hero(
                tag: 'croppedImage',
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 1,
                  maxScale: 5,
                  child: Image.memory(widget.imageData, fit: BoxFit.contain),
                ),
              ),
            ),
            // Optional: Back button or AppBar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedImageData {
  static String? base64Image;
}

class ImageFromBase64Screen extends StatelessWidget {
  const ImageFromBase64Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this string with your actual full Data URL
    const String imageBlob =
        "data:image/png;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUQEBIQFRAQFRAQFRUQEBUQFRAVFhUXFhUVFRUYHSggGBolGxUXITEhJSkrLi4uFx8zODMtNygtLisBCgoKDg0OGxAQGy0lHyUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIALcBEwMBIgACEQEDEQH/..."; // TRUNCATED

    try {
      // Get only the base64 part (after the comma)
      final base64Str = imageBlob.split(',').last;

      // Optional: Clean it (only needed if there's chance of invalid characters)
      final cleanedBase64 = base64Str.replaceAll(
        RegExp(r'[^A-Za-z0-9+/=]'),
        '',
      );

      // Decode to bytes
      Uint8List imageBytes = base64Decode(cleanedBase64);

      return Scaffold(
        appBar: AppBar(title: const Text('Decoded Image')),
        body: Center(child: Image.memory(imageBytes)),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('❌ Failed to decode image:\n$e')),
      );
    }
  }
}
