import 'package:camera/camera.dart';
import 'package:document_camera_frame/src/service/camera_service.dart';
import 'package:document_camera_frame/src/service/image_processing_service.dart';
import 'package:flutter/cupertino.dart';

class DocumentCameraController {
  final CameraService _cameraService = CameraService();
  final ImageProcessingService _imageProcessingService = ImageProcessingService();
  String _imagePath = '';

  String get imagePath => _imagePath;

  // Expose the cameraController for CameraPreview
  CameraController? get cameraController => _cameraService.cameraController;

  Future<void> initialize() async => _cameraService.initialize();

  bool get isInitialized => _cameraService.isInitialized;

  Future<void> takeAndCropPicture(double frameWidth, double frameHeight, BuildContext context) async {
    if (!_cameraService.isInitialized) return;

    try {
      final filePath = await _cameraService.captureImage();
      
      if (!context.mounted) return;

      _imagePath = _imageProcessingService.cropImageToFrame(filePath, frameWidth, frameHeight, context);
    } catch (e) {
      debugPrint('Error capturing or cropping image: $e');
    }
  }

  String saveImage() => imagePath;

  void retakeImage() => _imagePath = '';

  void resetImage() => _imagePath = '';

  void dispose() => _cameraService.dispose();
}
