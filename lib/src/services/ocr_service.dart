import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Reusable on-device OCR service using ML Kit.
///
/// Supports **Latin script** (English and other Latin-based languages).
/// Arabic is **not** supported by ML Kit's on-device model; for Arabic you would
/// need a cloud API (e.g. Firebase ML) or another SDK.
/// No API key or internet required for Latin.
class OcrService {
  /// Extracts text from an image file at [imagePath].
  /// Uses [TextRecognitionScript.latin] (English, etc.). Returns the full
  /// recognized text, or empty string if none. Always closes the recognizer.
  Future<String> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      await recognizer.close();
    }
  }
}
