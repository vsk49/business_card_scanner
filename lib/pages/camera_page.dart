import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:business_card_scanner/pages/confirmation_page.dart';
import 'package:business_card_scanner/services/ocr_service.dart';

class CameraPage extends StatefulWidget {
	const CameraPage({super.key});

	@override
	State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
	CameraController? _controller;
	final OcrService _ocrService = OcrService();
	bool _isReady = false;
	bool _isScanning = false;
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
			_controller = CameraController(cameras.first, ResolutionPreset.medium);
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
			ScaffoldMessenger.of(context)
				.showSnackBar(const SnackBar(content: Text('Camera is not ready yet.')));
			return;
		}
    	
		if (_controller!.value.isTakingPicture || _isScanning) return;

		try {
			setState(() => _isScanning = true);

			final image = await _controller!.takePicture();
			final scannedContact = await _ocrService.extractContactFromImage(
				image.path,
			);

			if (!mounted) return;
			setState(() => _isScanning = false);

			await showDialog<void>(
				context: context,
				builder: (context) {
					return ConfirmationPage(
						contactInfo: scannedContact,
						onConfirm: () {
							Navigator.of(context).pop(); // pops back to camera page
							ScaffoldMessenger.of(context).showSnackBar(
								const SnackBar(content: Text('Contact confirmed')),
							);
							Navigator.of(context).pop(); // then pops back to the home page
						},
						onTryAgain: () => Navigator.of(context).pop(),
					);
				},
			);
		} on CameraException catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Failed to capture image: ${e.code}')),
			);
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
			floatingActionButton: FloatingActionButton(
				onPressed: _isScanning ? null : _captureAndScan,
				tooltip: 'Take picture and scan',
				child: Icon(_isScanning ? Icons.hourglass_top : Icons.camera),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
		);
	}
}
