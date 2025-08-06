import 'package:camera/camera.dart';

import '../services/camera_service.dart';
import '../services/image_processing_service.dart';

class DocumentCameraController {
  final CameraService _cameraService = CameraService();
  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();
  String _imagePath = '';

  String get imagePath => _imagePath;
  int _currentCameraIndex = 0; // Track the current camera

  CameraController? get cameraController => _cameraService.cameraController;
  List<CameraDescription> cameras = [];

  ImageFormatGroup? _imageFormatGroup;

  Future<void> initialize(
    int cameraIndex, {
    ImageFormatGroup? imageFormatGroup,
  }) async {
    _imageFormatGroup = imageFormatGroup;

    cameras = await availableCameras(); // Load cameras only once
    if (cameras.isNotEmpty) {
      _currentCameraIndex = cameraIndex;
      await _cameraService.initialize(
        cameras[cameraIndex],
        imageFormatGroup: _imageFormatGroup,
      );
    }
  }

  Future<void> switchCamera() async {
    // Ensure multiple cameras exist
    if (cameras.isEmpty || cameras.length == 1) {
      return;
    }

    _currentCameraIndex =
        (_currentCameraIndex + 1) % cameras.length; // Toggle between cameras

    // Smooth transition: Pause before switching
    await cameraController?.pausePreview();
    await _cameraService.initialize(
      cameras[_currentCameraIndex],
      imageFormatGroup: _imageFormatGroup,
    );
    await cameraController?.resumePreview(); // Resume after switching
  }

  bool get isInitialized => _cameraService.isInitialized;

  Future<void> takeAndCropPicture(
    double frameWidth,
    double frameHeight,
    int screenWidth,
    int screenHeight,
  ) async {
    if (!_cameraService.isInitialized) return;
    try {
      final filePath = await _cameraService.captureImage();

      _imagePath = _imageProcessingService.cropImageToFrame(
        filePath,
        frameWidth,
        frameHeight,
        screenWidth,
        screenHeight,
      );
    } catch (e) {
      rethrow;
    }
  }

  String saveImage() => imagePath;

  void retakeImage() => _imagePath = '';

  void resetImage() => _imagePath = '';

  void dispose() => _cameraService.dispose();
}
