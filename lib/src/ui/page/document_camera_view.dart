import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../document_camera_controller.dart';
import '../../helper/document_camera_frame_painter.dart';
import '../widgets/action_button.dart';
import '../widgets/frame_capture_animation.dart';

class DocumentCameraView extends StatefulWidget {
  final double frameWidth;
  final double frameHeight;

  final Widget? screenTitle;
  final Alignment? screenTitleAlignment;
  final EdgeInsets? screenTitlePadding;

  final String? captureButtonText;
  final TextStyle? captureButtonTextStyle;
  final Function(String imgPath)? onCaptured;
  final ButtonStyle? captureButtonStyle;
  final Alignment? captureButtonAlignment;
  final EdgeInsets? captureButtonPadding;

  final String? saveButtonText;
  final TextStyle? saveButtonTextStyle;
  final Function(String imgPath)? onSaved;
  final ButtonStyle? saveButtonStyle;
  final Alignment? saveButtonAlignment;
  final EdgeInsets? saveButtonPadding;

  final String? retakeButtonText;
  final VoidCallback? onRetake;
  final TextStyle? retakeButtonTextStyle;
  final ButtonStyle? retakeButtonStyle;
  final Alignment? retakeButtonAlignment;
  final EdgeInsets? retakeButtonPadding;

  const DocumentCameraView({
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
  });

  @override
  State<DocumentCameraView> createState() => _DocumentCameraViewState();
}

class _DocumentCameraViewState extends State<DocumentCameraView> {
  late DocumentCameraController _controller;
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

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
              CameraPreview(_controller.cameraController!),
              Positioned.fill(
                child: CustomPaint(
                  painter: DocumentCameraFramePainter(
                    frameWidth: widget.frameWidth,
                    frameHeight: widget.frameHeight,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: widget.frameWidth,
                  height: widget.frameHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return FrameCaptureAnimation(
                      frameWidth: widget.frameWidth,
                      frameHeight: widget.frameHeight,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (_controller.imagePath.isNotEmpty)
                Center(
                  child: Container(
                    width: widget.frameWidth,
                    height: widget.frameHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 3),
                      image: DecorationImage(
                        image: FileImage(File(_controller.imagePath)),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              if (widget.screenTitle != null)
                Align(
                  alignment: widget.screenTitleAlignment ?? Alignment.topCenter,
                  child: Padding(
                    padding: widget.screenTitlePadding ?? const EdgeInsets.only(top: 50.0),
                    child: widget.screenTitle,
                  ),
                ),
              _buildActionButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: widget.captureButtonAlignment ?? Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller.imagePath.isEmpty)
            Padding(
              padding: widget.captureButtonPadding ?? const EdgeInsets.symmetric(vertical: 18.0),
              child: ActionButton(
                text: widget.captureButtonText ?? 'Capture',
                onPressed: () => _captureImage(widget.onCaptured),
                style: widget.captureButtonStyle,
                textStyle: widget.captureButtonTextStyle,
              ),
            ),
          if (_controller.imagePath.isNotEmpty) ...[
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
      ),
    );
  }

  Future<void> _captureImage(Function(String imgPath)? onCaptured) async {
    isLoadingNotifier.value = true;
    await _controller.takeAndCropPicture(widget.frameWidth, widget.frameHeight, context);

    if (onCaptured != null) {
      onCaptured(_controller.imagePath);
    }

    setState(() {});
    isLoadingNotifier.value = false;
  }

  void _saveImage(Function(String imgPath)? onSaved) {
    final imagePath = _controller.imagePath;

    if (onSaved != null) {
      onSaved(imagePath);
    }

    setState(() {
      _controller.retakeImage();
    });
  }

  void _retakeImage(VoidCallback? onRetake) {
    if (onRetake != null) {
      onRetake();
    }

    setState(() {
      _controller.retakeImage();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
