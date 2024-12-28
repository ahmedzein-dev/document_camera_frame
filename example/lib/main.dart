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
          frameWidth: 300.0,
          frameHeight: 200.0,
          title: Text(
            'Capture Your Document',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
