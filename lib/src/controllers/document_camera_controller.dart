import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_service.dart';
import '../services/image_processing_service.dart';

class DocumentCameraController {
  final CameraService _cameraService = CameraService();
  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();
  String _imagePath = '';

  String get imagePath => _imagePath;

  // Expose the cameraController for CameraPreview
  CameraController? get cameraController => _cameraService.cameraController;

  Future<void> initialize(int cameraIndex) async => _cameraService.initialize(cameraIndex);

  bool get isInitialized => _cameraService.isInitialized;

  Future<void> takeAndCropPicture(
      double frameWidth, double frameHeight, BuildContext context) async {
    if (!_cameraService.isInitialized) return;

    try {
      final filePath = await _cameraService.captureImage();

      if (!context.mounted) return;

      _imagePath = _imageProcessingService.cropImageToFrame(
          filePath, frameWidth, frameHeight, context);
    } catch (e) {
      log('Error capturing or cropping image: $e');
      rethrow;
    }
  }

  String saveImage() => imagePath;

  void retakeImage() => _imagePath = '';

  void resetImage() => _imagePath = '';

  void dispose() => _cameraService.dispose();
}
