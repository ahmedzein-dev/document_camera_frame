import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'image_converter_service.dart';

class DocumentDetectionService {
  /// Optional callback to report image processing errors.
  final void Function(Object error)? onError;

  DocumentDetectionService({this.onError});

  late final ObjectDetector _objectDetector;
  bool _isDetectorInitialized = false;

  /// Initializes the object detector.
  /// Must be called before `processImage`.
  void initialize() {
    if (_isDetectorInitialized) return;
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: false,
      multipleObjects: false,
    );
    _objectDetector = ObjectDetector(options: options);
    _isDetectorInitialized = true;
  }

  /// Processes a single camera image to detect if a document is aligned within the given frame.
  ///
  /// Returns `true` if a document is detected and well-aligned, otherwise `false`.

  Future<bool> processImage({
    required CameraImage image,
    required CameraController cameraController,
    required BuildContext context,
    required double frameWidth,
    required double frameHeight,
    required int screenWidth,
    required int screenHeight,
  }) async {
    if (!_isDetectorInitialized) {
      return false;
    }

    final inputImage = cameraImageToInputImage(image, cameraController);
    if (inputImage == null) {
      const errorMsg = 'Failed to convert CameraImage to InputImage.';
      onError?.call(Exception(errorMsg));
      return false;
    }

    try {
      final List<DetectedObject> objects = await _objectDetector.processImage(
        inputImage,
      );

      if (objects.isEmpty) {
        return false;
      }

      final detectedObject = objects.first;
      final boundingBox = detectedObject.boundingBox;

      // Step 1: Determine the correct analysis dimensions based on image rotation.
      // We assume a portrait UI, so if the image buffer is wider than it is tall, it's been rotated.
      final bool isImageRotated = image.width > image.height;
      final int analysisWidth = isImageRotated
          ? image.height
          : image.width; // Should be 2160
      final int analysisHeight = isImageRotated
          ? image.width
          : image.height; // Should be 3840

      // Step 2: Calculate the crop area in the *same coordinate system* as the ML Kit output.
      // We use the screen and frame dimensions to find the proportional crop rectangle.
      final int cropWidth = (frameWidth / screenWidth * analysisWidth).round();
      final int cropHeight = (frameHeight / screenHeight * analysisHeight)
          .round();

      final int cropX = (analysisWidth - cropWidth) ~/ 2;
      final int cropY = (analysisHeight - cropHeight) ~/ 2;

      // Step 3: Perform alignment checks in the consistent analysis coordinate system.
      final double objectArea = boundingBox.width * boundingBox.height;
      final double frameArea = (cropWidth * cropHeight)
          .toDouble(); // Use the calculated crop area

      // Size Alignment Check
      final bool sizeAligned =
          objectArea > (0.60 * frameArea) && objectArea < (0.95 * frameArea);

      // Optional: give 5-10% tolerance
      final double frameTolerance = 0.05;

      final double relaxedFrameTop = cropY * (1 - frameTolerance);

      // Position Alignment Check
      final bool positionAligned =
          boundingBox.left >= cropX &&
          boundingBox.top >= relaxedFrameTop &&
          boundingBox.right <= (cropX + cropWidth) &&
          boundingBox.bottom <= (cropY + cropHeight);

      final bool isAligned = sizeAligned && positionAligned;

      return isAligned;
    } catch (e) {
      onError?.call(e);
      return false;
    }
  }

  /// Closes the object detector and releases its resources.
  void dispose() {
    if (_isDetectorInitialized) {
      _objectDetector.close();
      _isDetectorInitialized = false;
    }
  }
}
