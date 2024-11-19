import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:document_camera_frame/src/context_extensions.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class LicenseCameraController {
  CameraController? cameraController;
  String imagePath = '';
  bool isLoading = false;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await cameraController!.initialize();
    }
  }

  bool get isInitialized => cameraController?.value.isInitialized ?? false;

  Future<void> takeAndCropPicture(double frameWidth, double frameHeight) async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (cameraController!.value.isTakingPicture) return;

    try {
      isLoading = true;
      final XFile picture = await cameraController!.takePicture();
      await picture.saveTo(filePath);
      imagePath = cropImageToFrame(filePath, frameWidth, frameHeight);
    } catch (e) {
      log('$e');
    } finally {
      isLoading = false;
    }
  }

  String cropImageToFrame(String filePath, double frameWidth, double frameHeight) {
    // Read the image from the file
    final File imageFile = File(filePath);
    final img.Image originalImage = img.decodeImage(imageFile.readAsBytesSync())!;

    // Calculate the screen dimensions
    final int screenWidth = 1.sw.toInt();
    final int screenHeight = 1.sh.toInt();

    log("screenWidth : $screenWidth");
    log("screenHeight : $screenHeight");
    log("ImageWidth : ${originalImage.width}");
    log("ImageHeight : ${originalImage.height}");
    // Calculate the dimensions for cropping based on frame and screen size
    final int cropWidth = originalImage.width * frameWidth ~/ screenWidth;
    final int cropHeight = originalImage.height * frameHeight ~/ screenHeight;

    log("cropWidth : $cropWidth");
    log("cropHeight : $cropHeight");

    // Calculate the horizontal and vertical coordinates for centering the crop area
    final int cropX = (originalImage.width - cropWidth) ~/ 2;
    final int cropY = (originalImage.height - cropHeight) ~/ 2;

    log("cropX : $cropX");
    log("cropY : $cropY");

    // Perform the cropping operation
    final img.Image croppedImage =
        img.copyCrop(originalImage, x: cropX, y: cropY, width: cropWidth, height: cropHeight);

    // Save the cropped image to a new file
    final String croppedFilePath = filePath.replaceAll('.jpg', '_cropped.jpg');
    final File croppedFile = File(croppedFilePath)..writeAsBytesSync(img.encodeJpg(croppedImage));

    return croppedFilePath;
  }

  String saveImage() {
    log("Image saved with title: $imagePath");
    return imagePath;
  }

  void retakeImage() {
    imagePath = '';
  }

  // Add this method to reset the image
  void resetImage() {
    imagePath = '';
  }

  void dispose() {
    cameraController?.dispose();
  }
}
