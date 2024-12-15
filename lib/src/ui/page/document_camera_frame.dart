import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../controllers/document_camera_controller.dart';
import '../../helper/document_camera_frame_painter.dart';
import '../widgets/action_button.dart';
import '../widgets/frame_capture_animation.dart';

/// A customizable camera view for capturing and cropping document images.
///
/// This widget provides a predefined frame for document capture,
/// along with buttons for capturing, saving, and retaking the document.
class DocumentCameraFrame extends StatefulWidget {
  /// Width of the document capture frame.
  final double frameWidth;

  /// Height of the document capture frame.
  final double frameHeight;

  /// Widget to display as the screen's title (optional).
  final Widget? screenTitle;

  /// Alignment of the screen title (optional).
  final Alignment? screenTitleAlignment;

  /// Padding for the screen title (optional).
  final EdgeInsets? screenTitlePadding;

  /// Text for the "Capture" button.
  final String? captureButtonText;

  /// Callback triggered when an image is captured.
  final Function(String imgPath)? onCaptured;

  /// Style for the "Capture" button (optional).
  final ButtonStyle? captureButtonStyle;

  /// Alignment of the "Capture" button (optional).
  final Alignment? captureButtonAlignment;

  /// Padding for the "Capture" button (optional).
  final EdgeInsets? captureButtonPadding;

  /// Text for the "Save" button.
  final String? saveButtonText;

  /// Callback triggered when an image is saved.
  final Function(String imgPath)? onSaved;

  /// Style for the "Save" button (optional).
  final ButtonStyle? saveButtonStyle;

  /// Alignment of the "Save" button (optional).
  final Alignment? saveButtonAlignment;

  /// Padding for the "Save" button (optional).
  final EdgeInsets? saveButtonPadding;

  /// Text for the "Retake" button.
  final String? retakeButtonText;

  /// Callback triggered when the "Retake" button is pressed.
  final VoidCallback? onRetake;

  /// Style for the "Retake" button (optional).
  final ButtonStyle? retakeButtonStyle;

  /// Alignment of the "Retake" button (optional).
  final Alignment? retakeButtonAlignment;

  /// Padding for the "Retake" button (optional).
  final EdgeInsets? retakeButtonPadding;

  /// Text style for the "Capture" button text (optional).
  ///
  /// **Important**: Avoid applying `textStyle` in the `ButtonStyle`
  /// To apply a custom text style to the text on the button,
  /// pass the style here. Do not pass it to the `ButtonStyle`
  /// as it may cause conflicts or errors.
  final TextStyle? captureButtonTextStyle;

  /// Text style for the "Save" button text (optional).
  ///
  /// **Note**: Same as above, apply text styling here.
  final TextStyle? saveButtonTextStyle;

  /// Text style for the "Retake" button text (optional).
  ///
  /// **Note**: Same as above, apply text styling here.
  final TextStyle? retakeButtonTextStyle;

  final BoxBorder? imageBorder;

  final Duration? animationDuration;

  final Color? animationColor;

  /// Constructor for the [DocumentCameraFrame].
  const DocumentCameraFrame({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.screenTitle,
    this.screenTitleAlignment,
    this.screenTitlePadding,
    this.captureButtonText,
    this.captureButtonTextStyle,
    this.onCaptured,
    this.captureButtonStyle,
    this.captureButtonAlignment,
    this.captureButtonPadding,
    this.saveButtonText,
    this.saveButtonTextStyle,
    this.onSaved,
    this.saveButtonStyle,
    this.saveButtonAlignment,
    this.saveButtonPadding,
    this.retakeButtonText,
    this.retakeButtonTextStyle,
    this.onRetake,
    this.retakeButtonStyle,
    this.retakeButtonAlignment,
    this.retakeButtonPadding,
    this.imageBorder,
    this.animationDuration,
    this.animationColor,
  });

  @override
  State<DocumentCameraFrame> createState() => _DocumentCameraFrameState();
}

class _DocumentCameraFrameState extends State<DocumentCameraFrame> {
  late DocumentCameraController _controller;
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String> capturedImageNotifier = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initializes the camera and updates the state when ready.
  Future<void> _initializeCamera() async {
    _controller = DocumentCameraController();
    await _controller.initialize();
    isInitializedNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: isInitializedNotifier,
        builder: (context, isInitialized, child) {
          if (!isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Display the camera preview
              CameraPreview(_controller.cameraController!),

              // Draw the document frame
              Positioned.fill(
                child: CustomPaint(
                  painter: DocumentCameraFramePainter(
                    frameWidth: widget.frameWidth,
                    frameHeight: widget.frameHeight,
                  ),
                ),
              ),

              // Center alignment of the document frame
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: widget.frameWidth,
                  height: widget.frameHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),

              // Frame capture animation when loading
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return FrameCaptureAnimation(
                      frameWidth: widget.frameWidth,
                      frameHeight: widget.frameHeight,
                      animationDuration: widget.animationDuration,
                      animationColor: widget.animationColor,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Display captured image
              ValueListenableBuilder<String>(
                valueListenable: capturedImageNotifier,
                builder: (context, imagePath, child) {
                  if (imagePath.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Container(
                      width: widget.frameWidth,
                      height: widget.frameHeight,
                      decoration: BoxDecoration(
                        border: widget.imageBorder ?? Border.all(color: Colors.green, width: 2),
                        image: DecorationImage(
                          image: FileImage(File(imagePath)),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Display optional screen title
              if (widget.screenTitle != null)
                Align(
                  alignment: widget.screenTitleAlignment ?? Alignment.topCenter,
                  child: Padding(
                    padding: widget.screenTitlePadding ?? const EdgeInsets.only(top: 50.0),
                    child: widget.screenTitle,
                  ),
                ),

              // Display action buttons
              _buildActionButtons(),
            ],
          );
        },
      ),
    );
  }

  /// Builds the action buttons for capture, save, and retake.
  Widget _buildActionButtons() {
    return Align(
      alignment: widget.captureButtonAlignment ?? Alignment.bottomCenter,
      child: ValueListenableBuilder<String>(
        valueListenable: capturedImageNotifier,
        builder: (context, imagePath, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath.isEmpty)
                Padding(
                  padding: widget.captureButtonPadding ?? const EdgeInsets.symmetric(vertical: 18.0),
                  child: ActionButton(
                    text: widget.captureButtonText ?? 'Capture',
                    onPressed: () => _captureImage(widget.onCaptured),
                    style: widget.captureButtonStyle,
                    textStyle: widget.captureButtonTextStyle,
                  ),
                )
              else ...[
                Padding(
                  padding: widget.saveButtonPadding ?? const EdgeInsets.symmetric(vertical: 18.0, horizontal: 4),
                  child: ActionButton(
                    text: widget.saveButtonText ?? 'Save',
                    onPressed: () => _saveImage(widget.onSaved),
                    style: widget.saveButtonStyle,
                    textStyle: widget.saveButtonTextStyle,
                  ),
                ),
                const SizedBox(width: 15),
                Padding(
                  padding: widget.retakeButtonPadding ?? const EdgeInsets.symmetric(vertical: 18.0, horizontal: 4),
                  child: ActionButton(
                    text: widget.retakeButtonText ?? 'Retake',
                    onPressed: () => _retakeImage(widget.onRetake),
                    style: widget.retakeButtonStyle,
                    textStyle: widget.retakeButtonTextStyle,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Captures the image and triggers the [onCaptured] callback.
  Future<void> _captureImage(Function(String imgPath)? onCaptured) async {
    isLoadingNotifier.value = true;
    await _controller.takeAndCropPicture(widget.frameWidth, widget.frameHeight, context);

    capturedImageNotifier.value = _controller.imagePath;

    if (onCaptured != null) {
      onCaptured(_controller.imagePath);
    }

    isLoadingNotifier.value = false;
  }

  /// Saves the captured image and triggers the [onSaved] callback.
  void _saveImage(Function(String imgPath)? onSaved) {
    final imagePath = _controller.imagePath;

    if (onSaved != null) {
      onSaved(imagePath);
    }

    _controller.resetImage();
  }

  /// Retakes the image and resets the UI.
  void _retakeImage(VoidCallback? onRetake) {
    if (onRetake != null) {
      onRetake();
    }

    _controller.retakeImage();

    capturedImageNotifier.value = _controller.imagePath;
  }

  @override
  void dispose() {
    _controller.dispose();
    isInitializedNotifier.dispose();
    isLoadingNotifier.dispose();
    capturedImageNotifier.dispose();
    super.dispose();
  }
}
