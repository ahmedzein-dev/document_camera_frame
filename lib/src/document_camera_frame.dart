import 'dart:io';

import 'package:camera/camera.dart';
import 'package:document_camera_frame/src/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'camera_frame_painter.dart';
import 'doc_camera_controller.dart';

class DocumentCameraFrame extends StatefulWidget {
  final String screenTitle;

  final double frameWidth;
  final double frameHeight;

  const DocumentCameraFrame({
    super.key,
    required this.screenTitle,
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  State<DocumentCameraFrame> createState() => _DocumentCameraFrameState();
}

class _DocumentCameraFrameState extends State<DocumentCameraFrame> {
  late LicenseCameraController _licenseCameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _licenseCameraController = LicenseCameraController();
    _initializeControllerFuture = _licenseCameraController.initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_licenseCameraController.cameraController!),
              Positioned.fill(
                child: CustomPaint(
                  painter: CameraFramePainter(frameWidth: widget.frameWidth, frameHeight: widget.frameHeight),
                  child: Container(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: widget.frameWidth,
                  height: widget.frameHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
              if (_licenseCameraController.isLoading)
                Center(
                  child: Container(
                    width: widget.frameWidth,
                    height: widget.frameHeight,
                    color: Colors.white.withOpacity(0.8),
                  )
                      .animate(onComplete: (controller) => controller.loop(period: const Duration(milliseconds: 1000)))
                      .fade(duration: const Duration(milliseconds: 1000)),
                ),
              if (_licenseCameraController.imagePath.isNotEmpty)
                Center(
                  child: Container(
                    width: widget.frameWidth,
                    height: widget.frameHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 3),
                      image: DecorationImage(
                        image: FileImage(File(_licenseCameraController.imagePath)),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(widget.screenTitle,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              Positioned(
                top: 0.75.sh + widget.frameHeight / 4 - 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_licenseCameraController.imagePath.isEmpty)
                      ElevatedButton(
                        onPressed: () async {
                          await _licenseCameraController.takeAndCropPicture(widget.frameWidth, widget.frameHeight);
                          setState(() {});
                        },
                        child: const Text("Capture"),
                      ),
                    if (_licenseCameraController.imagePath.isNotEmpty) ...[
                      ElevatedButton(
                        onPressed: () {
                          _licenseCameraController.saveImage();
                          setState(() {
                            _licenseCameraController.resetImage();
                          });
                        },
                        child: const Text("Save"),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _licenseCameraController.retakeImage();
                          });
                        },
                        child: const Text("Retake"),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _licenseCameraController.dispose();
    super.dispose();
  }
}
