import 'dart:io';
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
    final double scaleX = screenWidth / originalImage.width;
    final double scaleY = screenHeight / originalImage.height;
    final double coverScale = scaleX > scaleY ? scaleX : scaleY;

    int cropWidth = (frameWidth / coverScale).round();
    int cropHeight = (frameHeight / coverScale).round();
    if (cropWidth > originalImage.width) cropWidth = originalImage.width;
    if (cropHeight > originalImage.height) cropHeight = originalImage.height;

    final int cropX = (originalImage.width - cropWidth) ~/ 2;
    final int cropY = (originalImage.height - cropHeight) ~/ 2;

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
