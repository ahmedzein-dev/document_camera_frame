import 'package:camera/camera.dart';
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:document_camera_frame/src/ui/widgets/actions_buttons.dart';
import 'package:document_camera_frame/src/ui/widgets/animated_frame.dart';
import 'package:document_camera_frame/src/ui/widgets/screen_title.dart';
import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../widgets/bottom_frame_container.dart';
import '../widgets/captured_image_preview.dart';

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
  final Widget? title;

  /// Alignment of the screen title (optional).
  final Alignment? screenTitleAlignment;

  /// Padding for the screen title (optional).
  final EdgeInsets? screenTitlePadding;

  /// Radius of the outer circle of the capture button (optional).
  /// This defines the size of the outermost circle displayed.
  final double? captureOuterCircleRadius;

  ///	Radius of the inner circle of the capture button (optional).
  /// This defines the size of the innermost circle displayed.
  final double? captureInnerCircleRadius;

  /// Text for the "Capture" button.
  final String? captureButtonText;

  /// Callback triggered when an image is captured.
  final Function(String imgPath) onCaptured;

  /// Style for the "Capture" button (optional).
  final ButtonStyle? captureButtonStyle;

  /// Alignment of the "Capture" button (optional).
  final Alignment? captureButtonAlignment;

  /// Padding for the "Capture" button (optional).
  final EdgeInsets? captureButtonPadding;

  /// width for the "Capture" button (optional).
  final double? captureButtonWidth;

  /// height for the "Capture" button (optional).
  final double? captureButtonHeight;

  /// Text for the "Save" button.
  final String? saveButtonText;

  /// Callback triggered when an image is saved.
  final Function(String imgPath) onSaved;

  /// Style for the "Save" button (optional).
  final ButtonStyle? saveButtonStyle;

  /// Alignment of the "Save" button (optional).
  final Alignment? saveButtonAlignment;

  /// Padding for the "Save" button (optional).
  final EdgeInsets? saveButtonPadding;

  /// width for the "Save" button (optional).
  final double? saveButtonWidth;

  /// height for the "Save" button (optional).
  final double? saveButtonHeight;

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

  /// width for the "Retake" button (optional).
  final double? retakeButtonWidth;

  /// height for the "Retake" button (optional).
  final double? retakeButtonHeight;

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

  /// Border for the displayed Frame (optional).
  final BoxBorder? frameBorder;

  /// Duration for the capturing animation (optional).
  /// This controls how long the animation plays during the capture process.
  final Duration? capturingAnimationDuration;

  /// Color for the capturing animation (optional).
  /// Used to visually indicate the capture animation.
  final Color? capturingAnimationColor;

  /// Curve for the capturing animation (optional).
  /// Determines the easing of the animation during the capture process.
  final Curve? capturingAnimationCurve;

  /// Radius of the outer border of the frame.
  /// Controls the rounded edges of the outer frame.
  final double outerFrameBorderRadius;

  /// Radius of the inner corners of the frame.
  /// Controls the rounded edges of the inner frame corners.
  final double innerCornerBroderRadius;

  /// Duration for the frame animation (optional).
  /// Controls the animation timing for the frame.
  final Duration animatedFrameDuration;

  /// Curve for the frame animation (optional).
  /// Determines the easing of the frame animation.
  final Curve animatedFrameCurve;

  /// Child widget for the bottom frame container (optional).
  /// Allows for customization of the content displayed within the bottom container.
  final Widget? bottomFrameContainerChild;

  /// Flag to control the visibility of the CloseButton (optional).
  /// If `true`, the CloseButton will be displayed; otherwise, it will be hidden.
  final bool showCloseButton;

  /// Manually set camera index
  /// If null, camera 0 will be used.
  final int? cameraIndex;

  /// Constructor for the [DocumentCameraFrame].
  const DocumentCameraFrame({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.title,
    this.screenTitleAlignment,
    this.screenTitlePadding,
    this.captureButtonText,
    this.captureButtonTextStyle,
    required this.onCaptured,
    this.captureButtonStyle,
    this.captureButtonAlignment,
    this.captureButtonPadding,
    this.captureButtonWidth,
    this.captureButtonHeight,
    this.saveButtonText,
    this.saveButtonTextStyle,
    required this.onSaved,
    this.saveButtonStyle,
    this.saveButtonAlignment,
    this.saveButtonPadding,
    this.saveButtonWidth,
    this.saveButtonHeight,
    this.retakeButtonText,
    this.retakeButtonTextStyle,
    this.onRetake,
    this.retakeButtonStyle,
    this.retakeButtonAlignment,
    this.retakeButtonPadding,
    this.retakeButtonWidth,
    this.retakeButtonHeight,
    this.frameBorder,
    this.capturingAnimationDuration,
    this.capturingAnimationColor,
    this.animatedFrameDuration = const Duration(milliseconds: 400),
    this.animatedFrameCurve = Curves.easeIn,
    this.outerFrameBorderRadius = 12,
    this.innerCornerBroderRadius = 8,
    this.capturingAnimationCurve,
    this.bottomFrameContainerChild,
    this.captureInnerCircleRadius,
    this.captureOuterCircleRadius,
    this.showCloseButton = false,
    this.cameraIndex,
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
    await _controller.initialize(widget.cameraIndex ?? 0);
    isInitializedNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<bool>(
        valueListenable: isInitializedNotifier,
        builder: (context, isInitialized, child) => Stack(
          fit: StackFit.expand,
          children: [
            // Display the camera preview
            if (isInitialized) CameraPreview(_controller.cameraController!),

            /// Display captured image
            if (isInitialized)
              CapturedImagePreview(
                capturedImageNotifier: capturedImageNotifier,
                frameWidth: widget.frameWidth,
                frameHeight: widget.frameHeight,
                borderRadius: widget.outerFrameBorderRadius,
              ),

            /// Frame capture animation when loading
            if (isInitialized)
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return FrameCaptureAnimation(
                      frameWidth: widget.frameWidth,
                      frameHeight: widget.frameHeight,
                      animationDuration: widget.capturingAnimationDuration,
                      animationColor: widget.capturingAnimationColor,
                      curve: widget.capturingAnimationCurve,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            //  Draw the document frame
            Positioned.fill(
              child: CustomPaint(
                painter: DocumentCameraFramePainter(
                  frameWidth: widget.frameWidth,
                  frameHeight: widget.frameHeight +
                      AppConstants.bottomFrameContainerHeight,
                  borderRadius: widget.outerFrameBorderRadius,
                ),
              ),
            ),

            /// Border of the document frame
            ///
            /// CornerBorderBox of the document frame
            AnimatedFrame(
              frameWidth: widget.frameWidth,
              frameHeight: widget.frameHeight,
              outerFrameBorderRadius: widget.outerFrameBorderRadius,
              innerCornerBroderRadius: widget.innerCornerBroderRadius,
              animatedFrameDuration: widget.animatedFrameDuration,
              animatedFrameCurve: widget.animatedFrameCurve,
              border: widget.frameBorder,
            ),

            /// Frame Bottom Container
            BottomFrameContainer(
              width: widget.frameWidth,
              height: widget.frameHeight,
              borderRadius: widget.outerFrameBorderRadius,
              bottomFrameContainerChild: widget.bottomFrameContainerChild,
            ),

            /// Screen Title
            if (widget.title != null || widget.showCloseButton)
              ScreenTitle(
                title: widget.title,
                showCloseButton: widget.showCloseButton,
                screenTitleAlignment: widget.screenTitleAlignment,
                screenTitlePadding: widget.screenTitlePadding,
              ),

            /// Display action buttons
            ActionButtons(
              frameWidth: widget.frameWidth,
              frameHeight: widget.frameHeight,
              bottomFrameContainerHeight:
                  AppConstants.bottomFrameContainerHeight,
              capturedImageNotifier: capturedImageNotifier,
              isLoadingNotifier: isLoadingNotifier,
              onSave: widget.onSaved,
              onRetake: widget.onRetake,
              controller: _controller,
              onCaptured: widget.onCaptured,
              onSaved: widget.onSaved,
            ),
          ],
        ),
      ),
    );
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
