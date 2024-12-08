import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? cameraController;

  bool get isInitialized => cameraController != null && cameraController!.value.isInitialized;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await cameraController!.initialize();
    }
  }

  Future<String> captureImage() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final extDir = await getApplicationDocumentsDirectory();
    final dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);

    final filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final picture = await cameraController!.takePicture();
    await picture.saveTo(filePath);

    return filePath;
  }

  void dispose() {
    cameraController?.dispose();
  }
}
