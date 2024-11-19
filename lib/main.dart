import 'package:document_camera_frame/src/context_extensions.dart';
import 'package:document_camera_frame/src/document_camera_frame.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppContextProvider(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: DocumentCameraFrame(
          screenTitle: 'Camera Frame',
          frameWidth: 350,
          frameHeight: 250,
        ),
      ),
    );
  }
}
