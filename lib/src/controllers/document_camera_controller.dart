import 'package:camera/camera.dart';

import '../core/enums.dart';
import '../services/camera_service.dart';
import '../services/image_processing_service.dart';

class DocumentCameraController {
  final CameraService _cameraService = CameraService();
  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();
  String _imagePath = '';
  String _previewPath = '';

  String get imagePath => _imagePath;
  String get previewPath => _previewPath.isNotEmpty ? _previewPath : _imagePath;
  int _currentCameraIndex = 0; // Track the current camera

  CameraController? get cameraController => _cameraService.cameraController;
  List<CameraDescription> cameras = [];

  ImageFormatGroup? _imageFormatGroup;
  DocumentOutputFormat _outputFormat = DocumentOutputFormat.jpg;
  int _imageQuality = 90;
  FlashMode _initialFlashMode = FlashMode.auto;

  Future<void> initialize(
    int cameraIndex, {
    ImageFormatGroup? imageFormatGroup,
    FlashMode initialFlashMode = FlashMode.auto,
  }) async {
    _imageFormatGroup = imageFormatGroup;
    _initialFlashMode = initialFlashMode;

    cameras = await availableCameras(); // Load cameras only once
    if (cameras.isNotEmpty) {
      _currentCameraIndex = cameraIndex;
      await _cameraService.initialize(
        cameras[cameraIndex],
        imageFormatGroup: _imageFormatGroup,
        initialFlashMode: _initialFlashMode,
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
      initialFlashMode: _initialFlashMode,
    );
    await cameraController?.resumePreview(); // Resume after switching
  }

  bool get isInitialized => _cameraService.isInitialized;

  Future<void> takeAndCropPicture(
    double frameWidth,
    double frameHeight,
    int screenWidth,
    int screenHeight, {
    DocumentOutputFormat outputFormat = DocumentOutputFormat.jpg,
    int imageQuality = 90,
  }) async {
    if (!_cameraService.isInitialized) return;
    _outputFormat = outputFormat;
    _imageQuality = imageQuality;
    try {
      final filePath = await _cameraService.captureImage();

      final result = _imageProcessingService.cropImageToFrame(
        filePath,
        frameWidth,
        frameHeight,
        screenWidth,
        screenHeight,
        outputFormat: _outputFormat,
        imageQuality: _imageQuality,
      );

      _imagePath = result.filePath;
      _previewPath = result.previewPath ?? '';
    } catch (e) {
      rethrow;
    }
  }

  String saveImage() => imagePath;

  void retakeImage() {
    _imagePath = '';
    _previewPath = '';
  }

  void resetImage() {
    _imagePath = '';
    _previewPath = '';
  }

  void dispose() => _cameraService.dispose();
}
