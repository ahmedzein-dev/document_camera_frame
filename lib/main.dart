import 'package:document_camera_frame/src/ui/page/dd.dart';
import 'package:document_camera_frame/src/ui/page/document_camera_view.dart';
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
        body: Builder(
          builder: (context) => DocumentCameraView(
            frameWidth: 350,
            frameHeight: 400,
            screenTitle: const Text(
              'Custom Camera Title',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            //  captureButtonTextStyle: const TextStyle(fontSize: 24),
            // captureButtonStyle: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.white,
            //   foregroundColor: Colors.black,
            //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            // ),
            screenTitleAlignment: Alignment.topCenter,
            // Custom position for the title
            onCaptured: (String imgPath) {
              print('Custom Capture Button Pressed $imgPath');
            },
            captureButtonAlignment: Alignment.bottomRight,
            // Custom position for the capture button
            onSaved: (String imgPath) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Screen(imgPath: imgPath)),
              );
              print('Custom Save Button Pressed $imgPath');
            },
            saveButtonAlignment: Alignment.bottomLeft,
            // Custom position for the save button
            onRetake: () {
              print('Custom Retake Button Pressed');
            },
            retakeButtonAlignment: Alignment.bottomCenter, // Custom position for the retake button
          ),
        ),
      ),
    );
  }
}
