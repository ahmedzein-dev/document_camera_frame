import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Converts a [CameraImage] to an [InputImage] for ML Kit processing.
InputImage? cameraImageToInputImage(
  CameraImage image,
  CameraController cameraController,
) {
  final camera = cameraController.description;
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation;

  // Determine the rotation for ML Kit based on sensor orientation.
  // This is a common way to map it. Adjust if your camera setup requires different logic.
  switch (sensorOrientation) {
    case 0:
      rotation = InputImageRotation.rotation0deg;
      break;
    case 90:
      rotation = InputImageRotation.rotation90deg;
      break;
    case 180:
      rotation = InputImageRotation.rotation180deg;
      break;
    case 270:
      rotation = InputImageRotation.rotation270deg;
      break;
    default:
      rotation = InputImageRotation.rotation0deg; // Default to 0deg
  }

  final formatGroup = image.format.group;
  InputImageFormat? inputImageFormat;
  Uint8List bytes;

  // Determine the correct InputImageFormat for ML Kit
  // and prepare the bytes.
  if (formatGroup == ImageFormatGroup.yuv420 ||
      formatGroup == ImageFormatGroup.nv21) {
    // For YUV formats (including NV21 and YUV420_888),
    // ML Kit generally expects the bytes of all planes concatenated.
    // The specific 'InputImageFormat' will tell ML Kit how to interpret them.
    inputImageFormat = InputImageFormat
        .nv21; // Or yuv420 if your ML Kit version prefers it, but NV21 is often safer for generic YUV

    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    bytes = allBytes.done().buffer.asUint8List();
  } else if (formatGroup == ImageFormatGroup.bgra8888) {
    // For BGRA8888 (common on iOS), the bytes are typically in the first plane.
    inputImageFormat = InputImageFormat.bgra8888;
    bytes = image.planes[0].bytes;
  } else {
    debugPrint('Unsupported image format group: $formatGroup');
    return null;
  }

  // Ensure bytes is not null (shouldn't be with the above logic)
  if (bytes.isEmpty) {
    debugPrint('Image bytes are empty for format group: $formatGroup');
    return null;
  }

  final imageSize = Size(image.width.toDouble(), image.height.toDouble());

  // Create the metadata for ML Kit.
  // InputImageMetadata no longer takes 'planeData'.
  // 'bytesPerRow' is typically from the first plane for YUV formats.
  final inputImageData = InputImageMetadata(
    size: imageSize,
    rotation: rotation,
    format: inputImageFormat,
    // Provide bytesPerRow. It should be an int, not nullable.
    // Ensure image.planes[0].bytesPerRow is not null if it's coming from the camera plugin.
    bytesPerRow: image
        .planes[0]
        .bytesPerRow, // This assumes planes[0] is always available for relevant formats.
  );

  // Create and return the InputImage
  return InputImage.fromBytes(
    bytes: bytes,
    metadata: inputImageData, // Use 'metadata' parameter name
  );
}
