import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Converts a [CameraImage] (raw camera stream frame) to an [InputImage]
/// that ML Kit can process for object detection, barcode scanning, etc.
///
/// Returns [null] if the image format is unsupported or the bytes are empty.
InputImage? cameraImageToInputImage(
  CameraImage image,
  CameraController cameraController,
) {
  // ---------------------------------------------------------------------------
  // STEP 1: Determine Image Rotation
  // ---------------------------------------------------------------------------
  // ML Kit needs to know the orientation of the image to correctly process it.
  // The sensor orientation is a fixed value from the camera hardware (0, 90, 180, 270),
  // representing how many degrees the camera sensor is rotated relative to the device.
  // We map it directly to ML Kit's InputImageRotation enum.
  // Note: On Android, sensorOrientation is typically 90 or 270.
  //       On iOS, it is typically 0 or 90.
  // Adjust this logic if your device/setup requires different rotation handling.
  final rotation = switch (cameraController.description.sensorOrientation) {
    0 => InputImageRotation.rotation0deg,
    90 => InputImageRotation.rotation90deg,
    180 => InputImageRotation.rotation180deg,
    270 => InputImageRotation.rotation270deg,
    // Default to 0deg for any unexpected sensor orientation value.
    _ => InputImageRotation.rotation0deg,
  };

  // ---------------------------------------------------------------------------
  // STEP 2: Determine Image Format & Prepare Bytes
  // ---------------------------------------------------------------------------
  // Different platforms produce different raw image formats from the camera:
  //   - Android typically produces YUV420 or NV21.
  //   - iOS typically produces BGRA8888.
  // ML Kit requires both the correct format flag and the raw bytes
  // laid out in a specific way depending on the format.
  final formatGroup = image.format.group;
  final InputImageFormat inputImageFormat;
  final Uint8List bytes;

  if (formatGroup == ImageFormatGroup.yuv420 ||
      formatGroup == ImageFormatGroup.nv21) {
    // YUV formats use multiple planes (Y, U, V) to store color information separately.
    // ML Kit expects all plane bytes concatenated into a single byte array.
    // We use NV21 as the format flag — it is the most broadly compatible
    // option for generic YUV data in ML Kit. Use InputImageFormat.yuv420
    // if your specific ML Kit version or model requires it instead.
    inputImageFormat = InputImageFormat.nv21;

    // Concatenate all planes (Y, U, V) into one continuous byte buffer.
    final buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    bytes = buffer.done().buffer.asUint8List();
  } else if (formatGroup == ImageFormatGroup.bgra8888) {
    // BGRA8888 is an interleaved format common on iOS where all color channels
    // (Blue, Green, Red, Alpha) are packed together in a single plane.
    // No concatenation needed — we just read directly from the first (and only) plane.
    inputImageFormat = InputImageFormat.bgra8888;
    bytes = image.planes[0].bytes;
  } else {
    // Any other format (e.g., JPEG from some devices) is not currently supported.
    // Return null to skip this frame silently rather than crashing.
    debugPrint('[ImageConverter] Unsupported image format: $formatGroup');
    return null;
  }

  // Guard: If the byte array is somehow empty after the above processing,
  // there is nothing meaningful to pass to ML Kit — skip this frame.
  if (bytes.isEmpty) {
    debugPrint(
      '[ImageConverter] Image bytes are empty for format: $formatGroup',
    );
    return null;
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Determine bytesPerRow
  // ---------------------------------------------------------------------------
  // bytesPerRow (also called "stride") tells ML Kit how many bytes make up
  // one row of pixels in the image buffer — this may be larger than the image
  // width due to memory alignment padding added by the camera hardware.
  //
  // The camera plugin guarantees bytesPerRow is a non-null int (not int?),
  // so no null check is needed. However, we still guard against an unexpectedly
  // empty planes list as a defensive measure.
  //
  // Fallback: if planes is somehow empty, use image.width as the stride.
  // For NV21/YUV420, the Y plane stride equals the image width in most cases.
  final bytesPerRow = image.planes.isNotEmpty
      ? image.planes[0].bytesPerRow
      : image.width; // Fallback: stride equals width (no padding assumed)

  // ---------------------------------------------------------------------------
  // STEP 4: Build and Return the InputImage
  // ---------------------------------------------------------------------------
  // Combine the raw bytes with metadata (size, rotation, format, stride)
  // into an InputImage that ML Kit can consume directly.
  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // How the image is rotated relative to the screen
      format: inputImageFormat, // How the bytes are laid out (NV21 or BGRA8888)
      bytesPerRow:
          bytesPerRow, // Row stride in bytes (includes any hardware padding)
    ),
  );
}
