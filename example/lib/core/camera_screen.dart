import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';
import 'models.dart';

/// A thin wrapper that hosts [DocumentCameraFrame].
///
/// Navigation after save is handled by the package itself — it pops with
/// [DocumentCaptureData] as the result. The caller (SelectionScreen) awaits
/// Navigator.push and decides what screen comes next, keeping this widget
/// free of any post-save routing logic.
class CameraScreen extends StatelessWidget {
  const CameraScreen({
    super.key,
    required this.docInfo,
    required this.uiMode,
  });

  final DocTypeInfo docInfo;
  final DocumentCameraUIMode uiMode;

  @override
  Widget build(BuildContext context) {
    return DocumentCameraFrame(
      frameWidth: docInfo.frameWidth,
      frameHeight: docInfo.frameHeight,
      uiMode: uiMode,
      requireBothSides: docInfo.isTwoSided,
      // onDocumentSaved is optional here — the package pops with the result
      // automatically. Add a callback only if you need a side effect
      // (e.g. logging, analytics) before the screen closes.
      onDocumentSaved: (_) {},
    );
  }
}
