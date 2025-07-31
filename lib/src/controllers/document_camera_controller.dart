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
  int _currentCameraIndex = 0; // Track the current camera

  CameraController? get cameraController => _cameraService.cameraController;
  List<CameraDescription> cameras = [];

  Future<void> initialize(int cameraIndex) async {
    cameras = await availableCameras(); // Load cameras only once
    if (cameras.isNotEmpty) {
      _currentCameraIndex = cameraIndex;
      await _cameraService.initialize(cameras[cameraIndex]);
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
    await _cameraService.initialize(cameras[_currentCameraIndex]);
    await cameraController?.resumePreview(); // Resume after switching
  }

  bool get isInitialized => _cameraService.isInitialized;

  Future<void> takeAndCropPicture(
    double frameWidth,
    double frameHeight,
    BuildContext context,
  ) async {
    if (!_cameraService.isInitialized) return;
    try {
      final filePath = await _cameraService.captureImage();
      if (!context.mounted) return;
      _imagePath = _imageProcessingService.cropImageToFrame(
        filePath,
        frameWidth,
        frameHeight,
        context,
      );
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
