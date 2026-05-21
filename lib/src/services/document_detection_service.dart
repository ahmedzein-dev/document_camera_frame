import 'dart:math' show max;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../models/document_detection_config.dart';
import '../models/document_detection_status.dart';
import 'image_converter_service.dart';

/// Service responsible for detecting documents in a live camera stream.
///
/// Uses ML Kit's [ObjectDetector] to find objects in each camera frame,
/// then checks whether the best candidate is properly aligned within
/// the document frame shown on screen.
///
/// Usage:
/// ```dart
/// final service = DocumentDetectionService();
/// service.initialize();
/// final isAligned = await service.processImage(...);
/// service.dispose();
/// ```
class DocumentDetectionService {
  /// Optional callback invoked when an internal error occurs during processing.
  /// Useful for surfacing errors to the UI or logging layer without throwing.
  final void Function(Object error)? onError;

  /// Detection thresholds used during alignment evaluation.
  final DocumentDetectionConfig config;

  DocumentDetectionService({
    this.onError,
    this.config = const DocumentDetectionConfig(),
  });

  late final ObjectDetector _objectDetector;
  bool _isDetectorInitialized = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initializes the ML Kit [ObjectDetector] in stream mode.
  ///
  /// Must be called once before [processImage].
  /// Safe to call multiple times — subsequent calls are no-ops.
  ///
  /// Stream mode is used because we process continuous camera frames,
  /// not single static images. Multi-object detection is enabled so we
  /// can evaluate all candidates and pick the best match.
  void initialize() {
    if (_isDetectorInitialized) return;

    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream, // Optimized for live camera frames
      classifyObjects:
          false, // Classification not needed for document detection
      multipleObjects: true, // Detect all candidates, pick best one later
    );

    _objectDetector = ObjectDetector(options: options);
    _isDetectorInitialized = true;
    debugPrint(
      '[DocumentDetectionService] initialize: ObjectDetector initialized',
    );
  }

  /// Closes the [ObjectDetector] and releases its native resources.
  ///
  /// Must be called when the service is no longer needed (e.g., widget dispose).
  void dispose() {
    if (_isDetectorInitialized) {
      _objectDetector.close();
      _isDetectorInitialized = false;
      debugPrint('[DocumentDetectionService] dispose: ObjectDetector closed');
    }
  }

  // ---------------------------------------------------------------------------
  // Main Detection Pipeline
  // ---------------------------------------------------------------------------

  /// Processes a single [CameraImage] frame to detect document alignment.
  ///
  /// Returns `true` if a document is detected and well-aligned within
  /// the on-screen frame. Returns `false` otherwise.
  ///
  /// Parameters:
  /// - [image]                      : Raw camera frame from the image stream.
  /// - [cameraController]           : Active camera controller (used for sensor
  ///                                  orientation, preview size, lens direction).
  /// - [frameWidth] / [frameHeight] : Size of the document frame on screen (logical px).
  /// - [screenWidth] / [screenHeight] : Rendered preview dimensions on screen (logical px).
  /// - [onStatusUpdated]            : Optional callback with a user-facing guidance
  ///                                  message (e.g., 'Move closer').
  /// - [onDetectedRectUpdated]      : Optional callback with all detected bounding
  ///                                  boxes mapped to screen coordinates for overlay drawing.
  /// - [onBestDetectedRectUpdated]  : Optional callback with the single best
  ///                                  candidate rect mapped to screen coordinates.
  Future<bool> processImage({
    required CameraImage image,
    required CameraController cameraController,
    required BuildContext context,
    required double frameWidth,
    required double frameHeight,
    required int screenWidth,
    required int screenHeight,
    ValueChanged<String>? onStatusUpdated,
    ValueChanged<DocumentDetectionStatus>? onStatusNotified,
    ValueChanged<List<Rect>>? onDetectedRectUpdated,
    ValueChanged<Rect?>? onBestDetectedRectUpdated,
  }) async {
    // Guard: detector must be initialized before processing frames
    if (!_isDetectorInitialized) {
      debugPrint(
        '[DocumentDetectionService] processImage: Detector not initialized',
      );
      return false;
    }

    // ---------------------------------------------------------------------------
    // STEP 1: Convert CameraImage to InputImage for ML Kit
    // ---------------------------------------------------------------------------
    // ML Kit cannot consume a raw CameraImage directly. We convert it to an
    // InputImage with the correct format, rotation, and stride metadata.
    final inputImage = cameraImageToInputImage(image, cameraController);
    if (inputImage == null) {
      onError?.call(Exception('Failed to convert CameraImage to InputImage'));
      return false;
    }

    try {
      // ---------------------------------------------------------------------------
      // STEP 2: Run ML Kit object detection
      // ---------------------------------------------------------------------------
      final List<DetectedObject> objects = await _objectDetector.processImage(
        inputImage,
      );

      // If nothing was detected, notify the UI and return early
      if (objects.isEmpty) {
        onStatusUpdated?.call('No document found');
        onStatusNotified?.call(DocumentDetectionStatus.noDocumentFound);
        onDetectedRectUpdated?.call(<Rect>[]);
        onBestDetectedRectUpdated?.call(null);
        return false;
      }

      // ---------------------------------------------------------------------------
      // STEP 3: Determine analysis dimensions
      // ---------------------------------------------------------------------------
      // ML Kit returns bounding boxes in the "analysis coordinate system" —
      // the space in which it processed the image. This may differ from the
      // saved image pixel layout because the camera sensor is physically rotated.
      //
      // We detect rotation by comparing image buffer width vs height.
      // In a portrait UI, a wider-than-tall buffer means the sensor is rotated.
      final bool isImageRotated = image.width > image.height;
      final int analysisWidth = isImageRotated ? image.height : image.width;
      final int analysisHeight = isImageRotated ? image.width : image.height;

      // ---------------------------------------------------------------------------
      // STEP 4: Compute the frame rect in analysis coordinate space
      // ---------------------------------------------------------------------------
      // The camera preview is rendered with cover-fit (see _CoverFitCameraPreview):
      // a uniform coverScale maps analysis pixels to screen pixels so the larger
      // axis fills the screen exactly and the smaller axis overflows (clipped).
      // We invert that same scale to map the on-screen frame back to analysis space.
      final double displayWidth = screenWidth.toDouble();
      final double displayHeight = screenHeight.toDouble();

      // Uniform scale from analysis space to screen space under cover-fit.
      final double coverScale = max(
        displayWidth / analysisWidth,
        displayHeight / analysisHeight,
      );

      // Symmetric clip on each axis (the overflowing portion not visible on screen).
      final double horizontalClip =
          (analysisWidth * coverScale - displayWidth) / 2;
      final double verticalClip =
          (analysisHeight * coverScale - displayHeight) / 2;

      // Map the on-screen frame rect back to analysis coordinates.
      // The frame is centered, so this reduces to a simple center crop.
      final int cropWidth = (frameWidth / coverScale).round();
      final int cropHeight = (frameHeight / coverScale).round();
      final int cropX = (analysisWidth - cropWidth) ~/ 2;
      final int cropY = (analysisHeight - cropHeight) ~/ 2;

      // ---------------------------------------------------------------------------
      // STEP 5: Alignment thresholds (from config)
      // ---------------------------------------------------------------------------
      final double minSizeRatio = config.minSizeRatio;
      final double maxSizeRatio = config.maxSizeRatio;
      final double frameTolerance = config.frameTolerance;

      final double relaxedFrameTop = cropY * (1 - frameTolerance);
      final double relaxedFrameBottom =
          (cropY + cropHeight) * (1 + frameTolerance);
      final double frameArea = (cropWidth * cropHeight).toDouble();

      // The target aspect ratio of the document frame (portrait = height/width > 1)
      final double targetAspectRatio = frameHeight / frameWidth;

      // ---------------------------------------------------------------------------
      // STEP 6: Filter objects to candidates within the frame
      // ---------------------------------------------------------------------------
      // A candidate must satisfy both size and position constraints.
      final bool isFrontCamera =
          cameraController.description.lensDirection ==
          CameraLensDirection.front;

      final List<DetectedObject> filteredObjects = objects.where((object) {
        final rect = object.boundingBox;
        if (rect.width <= 0 || rect.height <= 0) return false;

        final double area = rect.width * rect.height;
        final bool sizeOk =
            area > (minSizeRatio * frameArea) &&
            area < (maxSizeRatio * frameArea);
        final bool posOk =
            rect.left >= cropX &&
            rect.top >= relaxedFrameTop &&
            rect.right <= (cropX + cropWidth) &&
            rect.bottom <= relaxedFrameBottom;
        return sizeOk && posOk;
      }).toList();

      // ---------------------------------------------------------------------------
      // STEP 7: Map all detected rects to screen coordinates for overlay drawing
      // ---------------------------------------------------------------------------
      // Convert analysis-space bounding boxes to screen-space rects so the UI
      // can draw highlight overlays. Front camera rects are mirrored horizontally.
      final List<Rect> detectedRectsOnScreen = filteredObjects
          .map(
            (object) => _mapBoundingBoxToScreenRect(
              boundingBox: object.boundingBox,
              analysisWidth: analysisWidth,
              analysisHeight: analysisHeight,
              displayWidth: displayWidth,
              displayHeight: displayHeight,
              coverScale: coverScale,
              horizontalClip: horizontalClip,
              verticalClip: verticalClip,
              isMirrored: isFrontCamera,
            ),
          )
          .whereType<Rect>()
          .toList();
      onDetectedRectUpdated?.call(detectedRectsOnScreen);

      // ---------------------------------------------------------------------------
      // STEP 8: Select the best candidate object
      // ---------------------------------------------------------------------------
      // If filtered candidates exist, pick the best among them.
      // Otherwise, fall back to all detected objects so we can still give
      // guidance even when no object fully satisfies the constraints.
      final List<DetectedObject> selectionPool = filteredObjects.isNotEmpty
          ? filteredObjects
          : objects;

      final DetectedObject bestObject = _selectBestDetectedObject(
        selectionPool,
        targetAspectRatio: targetAspectRatio,
      );

      // Map the best candidate to screen space and report it
      final Rect? bestRectOnScreen = _mapBoundingBoxToScreenRect(
        boundingBox: bestObject.boundingBox,
        analysisWidth: analysisWidth,
        analysisHeight: analysisHeight,
        displayWidth: displayWidth,
        displayHeight: displayHeight,
        coverScale: coverScale,
        horizontalClip: horizontalClip,
        verticalClip: verticalClip,
        isMirrored: isFrontCamera,
      );
      // Only surface the best rect if it passed all filters
      onBestDetectedRectUpdated?.call(
        filteredObjects.isNotEmpty ? bestRectOnScreen : null,
      );

      // ---------------------------------------------------------------------------
      // STEP 9: Final alignment evaluation
      // ---------------------------------------------------------------------------
      final Rect boundingBox = bestObject.boundingBox;
      final double objectArea = boundingBox.width * boundingBox.height;

      final bool sizeAligned =
          objectArea > (minSizeRatio * frameArea) &&
          objectArea < (maxSizeRatio * frameArea);

      final bool positionAligned =
          boundingBox.left >= cropX &&
          boundingBox.top >= relaxedFrameTop &&
          boundingBox.right <= (cropX + cropWidth) &&
          boundingBox.bottom <= relaxedFrameBottom;

      final bool isAligned = sizeAligned && positionAligned;

      // ---------------------------------------------------------------------------
      // STEP 10: Debug logging
      // ---------------------------------------------------------------------------
      final double sizeRatio = objectArea / frameArea * 100;
      debugPrint(
        '[DocumentDetectionService] processImage: '
        'size=${boundingBox.width.toStringAsFixed(1)}x'
        '${boundingBox.height.toStringAsFixed(1)}, '
        'area=${objectArea.toStringAsFixed(1)}, '
        'sizeRatio=${sizeRatio.toStringAsFixed(1)}% '
        '(threshold: ${(minSizeRatio * 100).toStringAsFixed(0)}-'
        '${(maxSizeRatio * 100).toStringAsFixed(0)}%), '
        'sizeAligned=$sizeAligned, positionAligned=$positionAligned',
      );

      debugPrint(
        '[DocumentDetectionService] processImage: '
        'Expected: left=$cropX, top=$cropY, '
        'right=${cropX + cropWidth}, bottom=${cropY + cropHeight}',
      );
      debugPrint(
        '[DocumentDetectionService] processImage: '
        'Actual: left=${boundingBox.left.toStringAsFixed(1)}, '
        'top=${boundingBox.top.toStringAsFixed(1)}, '
        'right=${boundingBox.right.toStringAsFixed(1)}, '
        'bottom=${boundingBox.bottom.toStringAsFixed(1)}',
      );

      // ---------------------------------------------------------------------------
      // STEP 11: Update UI guidance status message
      // ---------------------------------------------------------------------------
      // Compute directional adjustment hints when position is off
      final List<String> adjustments = [];
      bool overLeft = false;
      bool overRight = false;
      bool overTop = false;
      bool overBottom = false;

      if (!positionAligned) {
        overLeft = boundingBox.left < cropX;
        overRight = boundingBox.right > cropX + cropWidth;
        overTop = boundingBox.top < relaxedFrameTop;
        overBottom = boundingBox.bottom > relaxedFrameBottom;

        if (overLeft) adjustments.add('Move right');
        if (overRight) adjustments.add('Move left');

        if (overTop && overBottom) {
          adjustments.add('Document overflows top and bottom');
        } else if (overTop) {
          adjustments.add('Move down');
        } else if (overBottom) {
          adjustments.add('Move up');
        }
      }

      // Log size adjustment hint
      if (!sizeAligned) {
        if (objectArea < (minSizeRatio * frameArea)) {
          debugPrint(
            '[DocumentDetectionService] processImage: '
            'Size adjustment needed: Move closer',
          );
        } else if (objectArea > (maxSizeRatio * frameArea)) {
          debugPrint(
            '[DocumentDetectionService] processImage: '
            'Size adjustment needed: Move farther away',
          );
        }
      }

      // Emit the guidance message to the UI
      _updateDetectionStatus(
        onStatusUpdated,
        onStatusNotified,
        isAligned: isAligned,
        adjustments: adjustments,
        sizeAligned: sizeAligned,
        minSizeRatio: minSizeRatio,
        maxSizeRatio: maxSizeRatio,
        objectArea: objectArea,
        frameArea: frameArea,
        overLeft: overLeft,
        overRight: overRight,
        overTop: overTop,
        overBottom: overBottom,
      );

      return isAligned;
    } catch (e) {
      debugPrint('[DocumentDetectionService] processImage: Error — $e');
      onError?.call(e);
      onDetectedRectUpdated?.call(<Rect>[]);
      onBestDetectedRectUpdated?.call(null);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Selects the best [DetectedObject] from [objects] by comparing each
  /// candidate's aspect ratio against [targetAspectRatio].
  ///
  /// Ties in aspect ratio difference are broken by choosing the larger object,
  /// since a larger detection is more likely to represent the full document.
  DetectedObject _selectBestDetectedObject(
    List<DetectedObject> objects, {
    required double targetAspectRatio,
  }) {
    DetectedObject best = objects.first;
    double bestAspectDiff = double.infinity;
    double bestArea = -1;

    for (final object in objects) {
      final rect = object.boundingBox;
      if (rect.width <= 0 || rect.height <= 0) continue;

      final double aspectRatio = rect.height / rect.width;
      final double aspectDiff = (aspectRatio - targetAspectRatio).abs();
      final double area = rect.width * rect.height;

      // Prefer closer aspect ratio; break ties by larger area
      if (aspectDiff < bestAspectDiff ||
          (aspectDiff == bestAspectDiff && area > bestArea)) {
        best = object;
        bestAspectDiff = aspectDiff;
        bestArea = area;
      }
    }

    return best;
  }
}

// -----------------------------------------------------------------------------
// Top-Level Helpers
// (top-level for performance — avoids closure allocation on every frame)
// -----------------------------------------------------------------------------

/// Converts an ML Kit analysis-space [boundingBox] to a screen-space [Rect]
/// suitable for overlay drawing.
///
/// Accounts for:
/// - Cover-fit clipping offsets on both axes.
/// - Horizontal mirroring for front (selfie) cameras.
/// - Clamping to display bounds so overlays never render off-screen.
///
/// Returns `null` if the converted rect has zero or negative size after clamping.
Rect? _mapBoundingBoxToScreenRect({
  required Rect boundingBox,
  required int analysisWidth,
  required int analysisHeight,
  required double displayWidth,
  required double displayHeight,
  required double coverScale,
  required double horizontalClip,
  required double verticalClip,
  required bool isMirrored,
}) {
  if (analysisWidth == 0 || analysisHeight == 0) return null;

  // Under cover-fit both axes share a single scale; subtract the symmetric
  // clip offsets to convert from analysis space to visible screen space.
  double left = boundingBox.left * coverScale - horizontalClip;
  final double top = boundingBox.top * coverScale - verticalClip;
  final double width = boundingBox.width * coverScale;
  final double height = boundingBox.height * coverScale;

  // Mirror horizontally for front camera (selfie preview is flipped)
  if (isMirrored) {
    left = displayWidth - (left + width);
  }

  // Clamp to display bounds so the overlay rect never renders off-screen
  final double clampedLeft = left.clamp(0.0, displayWidth);
  final double clampedTop = top.clamp(0.0, displayHeight);
  final double clampedRight = (left + width).clamp(0.0, displayWidth);
  final double clampedBottom = (top + height).clamp(0.0, displayHeight);

  // Discard degenerate rects that have no visible area after clamping
  if (clampedRight <= clampedLeft || clampedBottom <= clampedTop) return null;

  return Rect.fromLTRB(clampedLeft, clampedTop, clampedRight, clampedBottom);
}

/// Emits a user-facing guidance message to [onStatusUpdated] based on the
/// current alignment state.
///
/// Message priority:
///   1. Aligned       → 'Hold still, capturing...'
///   2. Position off  → directional hints (Move right / left / up / down)
///   3. Size off      → 'Move closer' or 'Move farther away'
///   4. Both off      → combined position + size message
///   5. Fallback      → 'Adjust document position'
void _updateDetectionStatus(
  ValueChanged<String>? onStatusUpdated,
  ValueChanged<DocumentDetectionStatus>? onStatusNotified, {
  required bool isAligned,
  required List<String> adjustments,
  required bool sizeAligned,
  required double minSizeRatio,
  required double maxSizeRatio,
  required double objectArea,
  required double frameArea,
  required bool overLeft,
  required bool overRight,
  required bool overTop,
  required bool overBottom,
}) {
  // Resolve enum status first (drives both notifiers)
  final DocumentDetectionStatus status = _resolveStatus(
    isAligned: isAligned,
    sizeAligned: sizeAligned,
    objectTooSmall: objectArea < (minSizeRatio * frameArea),
    overLeft: overLeft,
    overRight: overRight,
    overTop: overTop,
    overBottom: overBottom,
  );
  onStatusNotified?.call(status);

  if (onStatusUpdated == null) return;

  // Document is fully aligned — prompt the user to hold still for capture
  if (isAligned) {
    onStatusUpdated('Perfect! Hold still to capture.');
    return;
  }

  // Build size guidance message if size is out of range
  String? sizeMessage;
  if (!sizeAligned) {
    if (objectArea < (minSizeRatio * frameArea)) {
      sizeMessage = 'Move closer'; // Document too small in frame
    } else if (objectArea > (maxSizeRatio * frameArea)) {
      sizeMessage = 'Move farther away'; // Document too large in frame
    }
  }

  // Build a concise, user-friendly message prioritizing size (far/close)
  // and simple movement hints (left/right/up/down).
  String message;
  if (sizeMessage != null && adjustments.isNotEmpty) {
    // Example: "Move closer and move right"
    message = '$sizeMessage and ${adjustments.join(', ').toLowerCase()}';
  } else if (sizeMessage != null) {
    // Example: "Move closer" or "Move farther away"
    message = sizeMessage;
  } else if (adjustments.isNotEmpty) {
    // Example: "Move right, move up"
    message = adjustments.join(', ');
  } else {
    message = 'Adjust document position';
  }

  onStatusUpdated(message);
}

/// Resolves the primary [DocumentDetectionStatus] from alignment boolean flags.
///
/// Priority: aligned > size (tooSmall/tooLarge) > overflow > directional > fallback.
DocumentDetectionStatus _resolveStatus({
  required bool isAligned,
  required bool sizeAligned,
  required bool objectTooSmall,
  required bool overLeft,
  required bool overRight,
  required bool overTop,
  required bool overBottom,
}) {
  if (isAligned) return DocumentDetectionStatus.aligned;
  if (!sizeAligned) {
    return objectTooSmall
        ? DocumentDetectionStatus.tooSmall
        : DocumentDetectionStatus.tooLarge;
  }
  if (overTop && overBottom) return DocumentDetectionStatus.documentOverflows;
  if (overLeft) return DocumentDetectionStatus.tooFarLeft;
  if (overRight) return DocumentDetectionStatus.tooFarRight;
  if (overTop) return DocumentDetectionStatus.tooHigh;
  if (overBottom) return DocumentDetectionStatus.tooLow;
  return DocumentDetectionStatus.adjustPosition;
}
