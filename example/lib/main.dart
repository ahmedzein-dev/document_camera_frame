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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document Capture Frame')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the DocumentCameraFrame example screen when the button is pressed
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DocumentCameraFrameExample()),
            );
          },
          child: const Text('Start Document Capture'),
        ),
      ),
    );
  }
}

class DocumentCameraFrameExample extends StatelessWidget {
  const DocumentCameraFrameExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DocumentCameraFrame(
        // Document frame dimensions
        frameWidth: 300.0,
        frameHeight: 200.0,

        // Title displayed at the top
        title: const Text(
          'Capture Your Document',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Show Close button
        showCloseButton: true,

        // Callback when the document is captured
        onCaptured: (imgPath) {
          debugPrint('Captured image path: $imgPath');
        },

        // Callback when the document is saved
        onSaved: (imgPath) {
          debugPrint('Saved image path: $imgPath');
        },

        // Callback when the retake button is pressed
        onRetake: () {
          debugPrint('Retake button pressed');
        },

        // Optional: Customize Capture button, Save button, etc. if needed
      ),
    );
  }
}
