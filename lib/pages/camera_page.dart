import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:business_card_scanner/models/contact.dart';
import 'package:business_card_scanner/pages/confirmation_page.dart';
import 'package:business_card_scanner/services/contact_saver_service.dart';
import 'package:business_card_scanner/services/ocr_service.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  final OcrService _ocrService = OcrService();
  final ContactSaverService _contactSaverService = ContactSaverService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isReady = false;
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _recoverLostGalleryImage();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No camera available. You can still import a photo.';
          _isReady = true;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isReady = true);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Camera error: ${e.code}');
    }
  }

  Future<void> _captureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera is not ready yet.')));
      return;
    }

    if (_controller!.value.isTakingPicture || _isScanning) return;

    try {
      final image = await _controller!.takePicture();
      await _scanImagePath(image.path);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: ${e.code}')),
      );
    }
  }

  Future<void> _pickAndScanFromGallery() async {
    if (_isScanning) return;

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      await _scanImagePath(image.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to import image: $e')));
    }
  }

  Future<void> _recoverLostGalleryImage() async {
    final response = await _imagePicker.retrieveLostData();
    if (!mounted || response.isEmpty) return;

    if (response.exception != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to recover image: ${response.exception}'),
        ),
      );
      return;
    }

    final image = response.file;
    if (image != null) {
      await _scanImagePath(image.path);
    }
  }

  Future<void> _scanImagePath(String imagePath) async {
    try {
      setState(() => _isScanning = true);

      final scannedContact = await _ocrService.extractContactFromImage(
        imagePath,
      );

      if (!mounted) return;
      setState(() => _isScanning = false);

      await _showConfirmationDialog(scannedContact);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan business card: $e')),
      );
    } finally {
      if (mounted && _isScanning) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _showConfirmationDialog(Contact scannedContact) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ConfirmationPage(
          contactInfo: scannedContact,
          onConfirm: (editedContact) async {
            try {
              await _contactSaverService.save(editedContact);
            } on ContactSavePermissionException {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contacts permission is needed to save.'),
                ),
              );
              return;
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save contact: $e')),
              );
              return;
            }
            if (!mounted || !dialogContext.mounted) return;
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${editedContact.name} added to contacts'),
              ),
            );
            Navigator.of(context).pop();
          },
          onTryAgain: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(child: Text(_errorMessage!)),
        floatingActionButton: _buildScanActions(showCameraButton: false),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    if (!_isReady || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: const Center(child: CircularProgressIndicator()),
        floatingActionButton: _buildScanActions(showCameraButton: false),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_isScanning)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Scanning...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildScanActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildScanActions({bool showCameraButton = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'gallery-scan',
          onPressed: _isScanning ? null : _pickAndScanFromGallery,
          tooltip: 'Import photo and scan',
          child: const Icon(Icons.photo_library),
        ),
        if (showCameraButton) ...[
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'camera-scan',
            onPressed: _isScanning ? null : _captureAndScan,
            tooltip: 'Take picture and scan',
            child: Icon(_isScanning ? Icons.hourglass_top : Icons.camera),
          ),
        ],
      ],
    );
  }
}
