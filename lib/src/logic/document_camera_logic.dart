import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/document_camera_controller.dart';
import '../core/app_constants.dart';
import '../core/enums.dart';
import '../models/document_capture_data.dart';
import '../services/document_detection_service.dart';
import '../services/ocr_service.dart';

class DocumentCameraLogic {
  final BuildContext context;
  final VoidCallback? onCameraError;
  final Function(String)? onFrontCaptured;
  final Function(String)? onBackCaptured;
  final Function(DocumentCaptureData)? onDocumentSaved;
  final bool enableExtractText;
  final VoidCallback? onRetake;
  final bool enableAutoCapture;
  final bool requireBothSides;
  final Duration frameFlipDuration;

  DocumentCameraLogic({
    required this.context,
    this.onCameraError,
    this.onFrontCaptured,
    this.onBackCaptured,
    this.onDocumentSaved,
    this.enableExtractText = false,
    this.onRetake,
    this.enableAutoCapture = false,
    this.requireBothSides = true,
    this.frameFlipDuration = const Duration(milliseconds: 1200),
  });

  Timer? _debounceTimer;
  bool _isDebouncing = false;

  final DocumentCameraController controller = DocumentCameraController();
  DocumentDetectionService? documentDetectionService;

  // State notifiers
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String> capturedImageNotifier = ValueNotifier("");
  final ValueNotifier<DocumentSide> currentSideNotifier = ValueNotifier(
    DocumentSide.front,
  );
  final ValueNotifier<DocumentCaptureData> documentDataNotifier = ValueNotifier(
    DocumentCaptureData(),
  );
  final ValueNotifier<bool> isDocumentAlignedNotifier = ValueNotifier(false);
  final ValueNotifier<String?> detectionStatusNotifier = ValueNotifier<String?>(
    null,
  );

  bool isDetectorBusy = false;
  bool isImageStreamActive = false;

  double updatedFrameWidth = 0;
  double updatedFrameHeight = 0;

  void initialize({
    required double frameWidth,
    required double frameHeight,
    int? cameraIndex,
  }) {
    _calculateFrameDimensions(frameWidth, frameHeight);
    _initializeComponents(cameraIndex);
  }

  void _calculateFrameDimensions(double frameWidth, double frameHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final maxWidth = screenWidth;
    final maxHeight = 0.45 * screenHeight;

    updatedFrameWidth = frameWidth > maxWidth ? maxWidth : frameWidth;
    updatedFrameHeight = frameHeight > maxHeight ? maxHeight : frameHeight;
  }

  Future<void> _initializeComponents(int? cameraIndex) async {
    if (enableAutoCapture) {
      documentDetectionService = DocumentDetectionService(
        onError: (e) => onCameraError?.call(),
      );
      documentDetectionService!.initialize();
    }

    await initializeCamera(cameraIndex);
  }

  Future<void> initializeCamera(int? cameraIndex) async {
    try {
      await controller.initialize(
        cameraIndex ?? 0,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      isInitializedNotifier.value = true;

      if (enableAutoCapture) {
        await startImageStream();
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      onCameraError?.call();
    }
  }

  Future<void> startImageStream() async {
    if (isImageStreamActive ||
        controller.cameraController == null ||
        !controller.cameraController!.value.isInitialized) {
      return;
    }

    try {
      await controller.cameraController!.startImageStream(processCameraImage);
      isImageStreamActive = true;
    } catch (e) {
      debugPrint('Failed to start image stream: $e');
      isImageStreamActive = false;
      onCameraError?.call();
    }
  }

  Future<void> stopImageStream() async {
    final camController = controller.cameraController;
    if (!isImageStreamActive ||
        camController == null ||
        !camController.value.isStreamingImages) {
      return;
    }

    try {
      await camController.stopImageStream();
    } catch (e) {
      debugPrint('Failed to stop image stream: $e');
      onCameraError?.call();
    } finally {
      isImageStreamActive = false;
    }
  }

  Future<void> processCameraImage(CameraImage image) async {
    if (isDetectorBusy || documentDetectionService == null) {
      return;
    }

    if (capturedImageNotifier.value.isNotEmpty) {
      if (isDocumentAlignedNotifier.value) {
        isDocumentAlignedNotifier.value = false;
      }
      return;
    }

    isDetectorBusy = true;

    try {
      final bool isAligned = await documentDetectionService!.processImage(
        image: image,
        cameraController: controller.cameraController!,
        context: context,
        frameWidth: updatedFrameWidth,
        frameHeight: updatedFrameHeight,
        screenWidth: MediaQuery.of(context).size.width.toInt(),
        screenHeight: MediaQuery.of(context).size.height.toInt(),
        onStatusUpdated: (status) {
          detectionStatusNotifier.value = status;
        },
      );

      isDocumentAlignedNotifier.value = isAligned;

      if (isAligned) {
        if (!_isDebouncing) {
          _isDebouncing = true;

          _debounceTimer = Timer(const Duration(seconds: 1), () async {
            if (isDocumentAlignedNotifier.value) {
              await captureAndHandleImageUnified(
                context,
                updatedFrameWidth,
                updatedFrameHeight + AppConstants.bottomFrameContainerHeight,
                MediaQuery.of(context).size.width.toInt(),
                MediaQuery.of(context).size.height.toInt(),
              );
            }
            _isDebouncing = false;
            _debounceTimer = null;
          });
        }
      } else {
        if (_isDebouncing) {
          _debounceTimer?.cancel();
          _debounceTimer = null;
          _isDebouncing = false;
        }
      }
    } catch (e) {
      debugPrint('Image processing error: $e');
      onCameraError?.call();
    } finally {
      isDetectorBusy = false;
    }
  }

  Future<void> captureAndHandleImageUnified(
    BuildContext context,
    double frameWidth,
    double frameHeight,
    int screenWidth,
    int screenHeight,
  ) async {
    if (isLoadingNotifier.value) {
      return;
    }

    isLoadingNotifier.value = true;

    try {
      if (enableAutoCapture && isImageStreamActive) {
        await stopImageStream();
      }

      await controller.takeAndCropPicture(
        frameWidth,
        frameHeight,
        screenWidth,
        screenHeight,
      );

      capturedImageNotifier.value = controller.imagePath;
      _handleCapture(controller.imagePath);
    } catch (e) {
      debugPrint('Capture failed: $e');
      onCameraError?.call();
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  void _handleCapture(String imagePath) {
    final currentSide = currentSideNotifier.value;
    final currentData = documentDataNotifier.value;

    if (currentSide == DocumentSide.front) {
      documentDataNotifier.value = currentData.copyWith(
        frontImagePath: imagePath,
      );
      onFrontCaptured?.call(imagePath);
    } else {
      documentDataNotifier.value = currentData.copyWith(
        backImagePath: imagePath,
      );
      onBackCaptured?.call(imagePath);
    }
  }

  void switchToBackSide() {
    currentSideNotifier.value = DocumentSide.back;
    controller.resetImage();
    capturedImageNotifier.value = controller.imagePath;

    if (enableAutoCapture) {
      restartImageStreamSafely();
    }
  }

  void switchToFrontSide() {
    currentSideNotifier.value = DocumentSide.front;
    final frontImagePath = documentDataNotifier.value.frontImagePath;

    if (frontImagePath != null && frontImagePath.isNotEmpty) {
      capturedImageNotifier.value = frontImagePath;
    } else {
      controller.resetImage();
      capturedImageNotifier.value = controller.imagePath;
    }

    if (enableAutoCapture &&
        (frontImagePath == null || frontImagePath.isEmpty)) {
      restartImageStreamSafely();
    }
  }

  Future<void> handleSave() async {
    final data = documentDataNotifier.value;
    if (!requireBothSides ||
        data.isCompleteFor(requireBothSides: requireBothSides)) {
      DocumentCaptureData resultData = data;
      if (enableExtractText) {
        isLoadingNotifier.value = true;
        try {
          final ocrService = OcrService();
          final frontPath = data.frontImagePath;
          final backPath = data.backImagePath;
          final results = await Future.wait<String?>([
            if (frontPath != null && frontPath.isNotEmpty)
              ocrService.extractText(frontPath)
            else
              Future<String?>.value(null),
            if (backPath != null && backPath.isNotEmpty)
              ocrService.extractText(backPath)
            else
              Future<String?>.value(null),
          ]);
          resultData = data.copyWith(
            frontOcrText: results[0],
            backOcrText: results[1],
          );
        } catch (e) {
          debugPrint('OCR extraction failed: $e');
        } finally {
          isLoadingNotifier.value = false;
        }
      }
      onDocumentSaved?.call(resultData);
      resetCapture();
    }
  }

  void handleRetake() {
    final currentSide = currentSideNotifier.value;
    final currentData = documentDataNotifier.value;

    if (currentSide == DocumentSide.front) {
      documentDataNotifier.value = currentData.copyWith(frontImagePath: "");
    } else {
      documentDataNotifier.value = currentData.copyWith(backImagePath: "");
    }

    controller.retakeImage();
    capturedImageNotifier.value = controller.imagePath;

    if (enableAutoCapture) {
      restartImageStreamSafely();
    }

    onRetake?.call();
  }

  Future<void> restartImageStreamSafely() async {
    try {
      if (isImageStreamActive) {
        await stopImageStream();
      }

      await Future.delayed(frameFlipDuration);

      await startImageStream();
    } catch (e) {
      debugPrint('Failed to restart image stream: $e');
      onCameraError?.call();
    }
  }

  void resetCapture() {
    controller.resetImage();
    capturedImageNotifier.value = controller.imagePath;
  }

  Future<void> switchCamera() async {
    isInitializedNotifier.value = false;
    if (enableAutoCapture) {
      await stopImageStream();
    }

    await controller.switchCamera();
    isInitializedNotifier.value = true;

    if (enableAutoCapture) {
      await startImageStream();
    }
  }

  void dispose() {
    disposeAsync();
    controller.dispose();
    documentDetectionService?.dispose();
    isInitializedNotifier.dispose();
    isLoadingNotifier.dispose();
    capturedImageNotifier.dispose();
    currentSideNotifier.dispose();
    documentDataNotifier.dispose();
    isDocumentAlignedNotifier.dispose();
    detectionStatusNotifier.dispose();
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  Future<void> disposeAsync() async {
    if (enableAutoCapture) {
      await stopImageStream();
    }
  }
}
