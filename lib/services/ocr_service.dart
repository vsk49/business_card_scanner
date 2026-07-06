import 'package:business_card_scanner/models/contact.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
	final TextRecognizer _textRecognizer = TextRecognizer(
		script: TextRecognitionScript.latin,
	);

	Future<Contact> extractContactFromImage(String imagePath) async {
		final inputImage = InputImage.fromFilePath(imagePath);
		final recognizedText = await _textRecognizer.processImage(inputImage);

		return Contact.fromOcrText(recognizedText.text);
	}

	Future<void> dispose() => _textRecognizer.close();
}
