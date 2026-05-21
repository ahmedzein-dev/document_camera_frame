import 'dart:io';
import 'dart:math' show max;

import 'package:image/image.dart' as img;

import '../core/enums.dart';

class CropResult {
  final String filePath;
  final String? previewPath;

  CropResult({required this.filePath, this.previewPath});
}

class ImageProcessingService {
  /// Crops the captured image to the frame dimensions and saves in the specified format
  ///
  /// [filePath] - Path to the original captured image
  /// [frameWidth] - Width of the capture frame
  /// [frameHeight] - Height of the capture frame
  /// [screenWidth] - Width of the screen
  /// [screenHeight] - Height of the screen
  /// [outputFormat] - Desired output format (default: JPG)
  /// [imageQuality] - Quality for lossy formats like JPG and WebP (1-100, default: 90)
  ///
  /// Returns a [CropResult] containing the path to the cropped image and an optional preview path
  CropResult cropImageToFrame(
    String filePath,
    double frameWidth,
    double frameHeight,
    int screenWidth,
    int screenHeight, {
    DocumentOutputFormat outputFormat = DocumentOutputFormat.jpg,
    int imageQuality = 90,
  }) {
    final File imageFile = File(filePath);
    final img.Image originalImage = img.decodeImage(
      imageFile.readAsBytesSync(),
    )!;

    // The preview is rendered with cover-fit (see _CoverFitCameraPreview):
    // the captured image is scaled by `coverScale = max(scrW/imgW, scrH/imgH)`
    // and centered, with the longer axis overflowing off-screen. To map the
    // on-screen frame back to image-pixel space we divide by that same scale,
    // which keeps the crop rectangle visually identical to the frame the user
    // saw — no aspect distortion, no offset.
    //
    // On some Android devices decodeImage returns the sensor-native (landscape)
    // bytes without applying the EXIF rotation tag. When the decoded dimensions
    // disagree with the screen orientation we swap the effective image width/height
    // so coverScale is computed against the visual (portrait) proportions.
    final bool orientationMismatch =
        (originalImage.width > originalImage.height) != (screenWidth > screenHeight);
    final double effectiveImgW = orientationMismatch
        ? originalImage.height.toDouble()
        : originalImage.width.toDouble();
    final double effectiveImgH = orientationMismatch
        ? originalImage.width.toDouble()
        : originalImage.height.toDouble();

    final double coverScale = max(screenWidth / effectiveImgW, screenHeight / effectiveImgH);

    // Clamp dimensions first so the origin clamp below never sees a negative range.
    int cropWidth = (frameWidth / coverScale).round().clamp(0, originalImage.width);
    int cropHeight = (frameHeight / coverScale).round().clamp(0, originalImage.height);

    // Center the crop; clamp origin so floating-point rounding never exceeds bounds.
    int cropX = ((originalImage.width - cropWidth) ~/ 2).clamp(0, originalImage.width - cropWidth);
    int cropY = ((originalImage.height - cropHeight) ~/ 2).clamp(0, originalImage.height - cropHeight);

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Determine file extension and encoding based on format
    String extension;
    List<int> encodedBytes;
    String? previewPath;

    // Helper to generate path without relying on .jpg extension
    String getNewPath(String originalPath, String suffix) {
      final int lastDotIndex = originalPath.lastIndexOf('.');
      if (lastDotIndex != -1) {
        return '${originalPath.substring(0, lastDotIndex)}$suffix';
      }
      return '$originalPath$suffix';
    }

    switch (outputFormat) {
      case DocumentOutputFormat.jpg:
        extension = '.jpg';
        encodedBytes = img.encodeJpg(croppedImage, quality: imageQuality);
        break;
      case DocumentOutputFormat.png:
        extension = '.png';
        encodedBytes = img.encodePng(croppedImage);
        break;
      case DocumentOutputFormat.tiff:
        extension = '.tiff';
        encodedBytes = img.encodeTiff(croppedImage);

        // Generate a JPG preview for TIFF because Flutter's Image widget can't decode TIFF
        final String previewFilePath = getNewPath(filePath, '_preview.jpg');
        final List<int> previewBytes = img.encodeJpg(
          croppedImage,
          quality: 70,
        ); // Lower quality for preview
        File(previewFilePath).writeAsBytesSync(previewBytes);
        previewPath = previewFilePath;
        break;
      case DocumentOutputFormat.pdf:
        // For PDF, we still save as JPG first, then convert to PDF later
        extension = '.jpg';
        encodedBytes = img.encodeJpg(croppedImage, quality: imageQuality);
        break;
    }

    final String croppedFilePath = getNewPath(filePath, '_cropped$extension');
    File(croppedFilePath).writeAsBytesSync(encodedBytes);

    return CropResult(filePath: croppedFilePath, previewPath: previewPath);
  }
}
