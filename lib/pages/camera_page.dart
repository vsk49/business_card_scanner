import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:business_card_scanner/pages/confirmation_page.dart';

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

  	Future<void> _captureAndScan() async {
		if (_controller == null || !_controller!.value.isInitialized) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Camera is not ready yet.')),
			);
			return;
		}

		if (_controller!.value.isTakingPicture) return;

    	try {
			await _controller!.takePicture();
			if (!mounted) return;

			final scannedContact = {
				'name': 'Jane Smith',
				'phone': '+1 555-0123',
				'email': 'jane.smith@example.com',
				'company': 'Acme Corp',
			};

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
			floatingActionButton: FloatingActionButton(
				onPressed: _captureAndScan,
				tooltip: 'Take picture and scan',
				child: const Icon(Icons.camera),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
		);
	}
}