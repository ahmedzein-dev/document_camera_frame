import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'result_screen.dart';

class CameraScreen extends StatelessWidget {
  final DocTypeInfo docInfo;
  final DocumentCameraUIMode uiMode;

  const CameraScreen({
    super.key,
    required this.docInfo,
    required this.uiMode,
  });

  void _onSaved(BuildContext context, DocumentCaptureData data) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(documentData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No logic here — the package handles everything based on uiMode:
    // auto-capture, detection text, OCR, side indicator, instructions.
    return DocumentCameraFrame(
      frameWidth: docInfo.frameWidth,
      frameHeight: docInfo.frameHeight,
      uiMode: uiMode,
      requireBothSides: docInfo.isTwoSided,
      onDocumentSaved: (data) => _onSaved(context, data),
    );
  }
}
