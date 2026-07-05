import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No camera available.');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() => _isReady = true);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Camera error: ${e.code}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (!_isReady || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: CameraPreview(_controller!),
    );
  }
}