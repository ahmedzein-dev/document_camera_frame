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
        body: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document camera frame example')),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DocumentCameraFrameExample()));
            },
            child: Text('Open document camera frame')),
      ),
    );
  }
}

class DocumentCameraFrameExample extends StatelessWidget {
  const DocumentCameraFrameExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentCameraFrame(
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
      showCloseButton: true,
      onCaptured: (imgPath) {
        debugPrint('Captured image path: $imgPath');
      },
      onSaved: (imgPath) {
        debugPrint('Saved image path: $imgPath');
      },
      onRetake: () {
        debugPrint('Retake button pressed');
      },
    );
  }
}
