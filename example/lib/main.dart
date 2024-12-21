import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: DocumentCameraFrame(
          frameWidth: 330.0,
          frameHeight: 240.0,
          // captureButtonTextStyle: const TextStyle(fontSize: 24),
          // captureButtonStyle: ElevatedButton.styleFrom(
          //   backgroundColor: Colors.white,
          //   foregroundColor: Colors.black,
          //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          // ),
          // captureButtonWidth: 140,
          // captureButtonHeight: 40,
          screenTitle: const Text(
            'Capture Your Document',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          captureButtonText: 'Snap',
          saveButtonText: 'Keep',
          retakeButtonText: 'Retry',
          onCaptured: (imgPath) {
            debugPrint('Captured image path: $imgPath');
          },
          onSaved: (imgPath) {
            debugPrint('Saved image path: $imgPath');
          },
          onRetake: () {
            debugPrint('Retake button pressed');
          },
        ),
      ),
    );
  }
}
