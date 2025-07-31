import 'package:camera/camera.dart';
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

import '../../core/app_constants.dart';

/// A customizable camera view for capturing both sides of document images.
///
/// This widget provides a predefined frame for document capture,
/// with support for capturing front and back sides of documents.
class DocumentCameraFrame extends StatefulWidget {
  /// Width of the document capture frame.
  final double frameWidth;

  /// Height of the document capture frame.
  final double frameHeight;

  /// Widget to display as the screen's title (optional).
  final Widget? title;

  /// Custom title for front side capture
  final Widget? frontSideTitle;

  /// Custom title for back side capture
  final Widget? backSideTitle;

  /// Alignment of the screen title (optional).
  final Alignment? screenTitleAlignment;

  /// Padding for the screen title (optional).
  final EdgeInsets? screenTitlePadding;

  /// Radius of the outer circle of the capture button (optional).
  final double? captureOuterCircleRadius;

  /// Radius of the inner circle of the capture button (optional).
  final double? captureInnerCircleRadius;

  /// Text for the "Capture" button.
  final String? captureButtonText;

  /// Text for capture button when capturing front side
  final String? captureFrontButtonText;

  /// Text for capture button when capturing back side
  final String? captureBackButtonText;

  /// Callback triggered when front side is captured.
  final Function(String imgPath)? onFrontCaptured;

  /// Callback triggered when back side is captured.
  final Function(String imgPath)? onBackCaptured;

  /// Callback triggered when both sides are captured and saved.
  final Function(DocumentCaptureData documentData) onBothSidesSaved;

  /// Style for the "Capture" button (optional).
  final ButtonStyle? captureButtonStyle;

  /// Alignment of the "Capture" button (optional).
  final Alignment? captureButtonAlignment;

  /// Padding for the "Capture" button (optional).
  final EdgeInsets? captureButtonPadding;

  /// Width for the "Capture" button (optional).
  final double? captureButtonWidth;

  /// Height for the "Capture" button (optional).
  final double? captureButtonHeight;

  /// Text for the "Save" button.
  final String? saveButtonText;

  /// Text for "Next" button (when moving from front to back)
  final String? nextButtonText;

  /// Text for "Previous" button (when going back to front from back)
  final String? previousButtonText;

  /// Style for action buttons (optional).
  final ButtonStyle? actionButtonStyle;

  /// Alignment of action buttons (optional).
  final Alignment? actionButtonAlignment;

  /// Padding for action buttons (optional).
  final EdgeInsets? actionButtonPadding;

  /// Width for action buttons (optional).
  final double? actionButtonWidth;

  /// Height for action buttons (optional).
  final double? actionButtonHeight;

  /// Text for the "Retake" button.
  final String? retakeButtonText;

  /// Callback triggered when the "Retake" button is pressed.
  final VoidCallback? onRetake;

  /// Style for the "Retake" button (optional).
  final ButtonStyle? retakeButtonStyle;

  /// Text styles for buttons
  final TextStyle? captureButtonTextStyle;
  final TextStyle? actionButtonTextStyle;
  final TextStyle? retakeButtonTextStyle;

  /// Border for the displayed Frame (optional).
  final BoxBorder? frameBorder;

  /// Animation properties
  final Duration? capturingAnimationDuration;
  final Color? capturingAnimationColor;
  final Curve? capturingAnimationCurve;
  final Duration animatedFrameDuration;
  final Duration flipAnimationDuration;
  final Curve flipAnimationCurve;
  final Curve animatedFrameCurve;

  /// Frame styling
  final double outerFrameBorderRadius;
  final double innerCornerBroderRadius;

  /// Bottom container customization
  final Widget? bottomFrameContainerChild;

  /// Show close button
  final bool showCloseButton;

  /// Camera index
  final int? cameraIndex;

  /// Whether to require both sides (if false, can save with just front side)
  final bool requireBothSides;

  /// Progress indicator properties
  final Color? progressIndicatorColor;
  final double progressIndicatorHeight;

  /// Instruction text for each side
  final String? frontSideInstruction;
  final String? backSideInstruction;
  final TextStyle? instructionTextStyle;

  /// Optional bottom hint text shown in the bottom container.
  final String? bottomHintText;

  /// Optional widget shown on the right (e.g. a check icon).
  final Widget? sideInfoOverlay;

  /// Show the side indicator (optional)
  final bool showSideIndicator;

  /// Customize side indicator colors and style
  final Color? sideIndicatorBackgroundColor;
  final Color? sideIndicatorBorderColor;
  final Color? sideIndicatorActiveColor;
  final Color? sideIndicatorInactiveColor;
  final Color? sideIndicatorCompletedColor;
  final TextStyle? sideIndicatorTextStyle;

  /// Constructor for the [DocumentCameraFrame].
  const DocumentCameraFrame({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.title,
    this.frontSideTitle,
    this.backSideTitle,
    this.screenTitleAlignment,
    this.screenTitlePadding,
    this.captureOuterCircleRadius,
    this.captureInnerCircleRadius,
    this.captureButtonText,
    this.captureFrontButtonText,
    this.captureBackButtonText,
    this.onFrontCaptured,
    this.onBackCaptured,
    required this.onBothSidesSaved,
    this.captureButtonStyle,
    this.captureButtonAlignment,
    this.captureButtonPadding,
    this.captureButtonWidth,
    this.captureButtonHeight,
    this.saveButtonText,
    this.nextButtonText,
    this.previousButtonText,
    this.actionButtonStyle,
    this.actionButtonAlignment,
    this.actionButtonPadding,
    this.actionButtonWidth,
    this.actionButtonHeight,
    this.retakeButtonText,
    this.onRetake,
    this.retakeButtonStyle,
    this.captureButtonTextStyle,
    this.actionButtonTextStyle,
    this.retakeButtonTextStyle,
    this.frameBorder,
    this.capturingAnimationDuration,
    this.capturingAnimationColor,
    this.capturingAnimationCurve,
    this.animatedFrameDuration = const Duration(milliseconds: 600),
    this.flipAnimationDuration = const Duration(milliseconds: 1200),
    this.flipAnimationCurve = Curves.easeInOut,
    this.animatedFrameCurve = Curves.easeInOut,
    this.outerFrameBorderRadius = 12,
    this.innerCornerBroderRadius = 8,
    this.bottomFrameContainerChild,
    this.showCloseButton = false,
    this.cameraIndex,
    this.requireBothSides = true,
    this.progressIndicatorColor,
    this.progressIndicatorHeight = 4.0,
    this.frontSideInstruction,
    this.backSideInstruction,
    this.instructionTextStyle,
    this.bottomHintText,
    this.sideInfoOverlay,
    this.showSideIndicator = true,
    this.sideIndicatorBackgroundColor,
    this.sideIndicatorBorderColor,
    this.sideIndicatorActiveColor,
    this.sideIndicatorInactiveColor,
    this.sideIndicatorCompletedColor,
    this.sideIndicatorTextStyle,
  });

  @override
  State<DocumentCameraFrame> createState() => _DocumentCameraFrameState();
}

class _DocumentCameraFrameState extends State<DocumentCameraFrame>
    with TickerProviderStateMixin {
  late DocumentCameraController _controller;
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String> capturedImageNotifier = ValueNotifier("");

  // Two-sided document specific state
  final ValueNotifier<DocumentSide> currentSideNotifier = ValueNotifier(
    DocumentSide.front,
  );
  final ValueNotifier<DocumentCaptureData> documentDataNotifier = ValueNotifier(
    DocumentCaptureData(),
  );

  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Initializes the camera and updates the state when ready.
  Future<void> _initializeCamera() async {
    _controller = DocumentCameraController();
    await _controller.initialize(widget.cameraIndex ?? 0);
    isInitializedNotifier.value = true;
  }

  /// Handle image capture based on current side
  void _handleCapture(String imagePath) {
    final currentSide = currentSideNotifier.value;
    final currentData = documentDataNotifier.value;

    if (currentSide == DocumentSide.front) {
      documentDataNotifier.value = currentData.copyWith(
        frontImagePath: imagePath,
      );
      widget.onFrontCaptured?.call(imagePath);

      // Auto-progress to back side if both sides are required
      if (widget.requireBothSides) {
        // Don't auto-switch immediately, let user see the captured image first
        // They can click "Next Side" button to proceed
      }
    } else {
      documentDataNotifier.value = currentData.copyWith(
        backImagePath: imagePath,
      );
      widget.onBackCaptured?.call(imagePath);
    }
  }

  /// Switch to back side capture
  void _switchToBackSide() {
    currentSideNotifier.value = DocumentSide.back;
    // Reset the controller for new capture
    _controller.retakeImage();
    capturedImageNotifier.value = _controller.imagePath;
    _progressAnimationController.animateTo(1.0);
  }

  /// Switch to front side capture
  void _switchToFrontSide() {
    currentSideNotifier.value = DocumentSide.front;
    // Show the previously captured front image if it exists
    final frontImagePath = documentDataNotifier.value.frontImagePath;
    if (frontImagePath != null && frontImagePath.isNotEmpty) {
      capturedImageNotifier.value = frontImagePath;
      // Note: We can't set the controller's imagePath directly as it's read-only
      // The controller will be reset when user takes a new picture
    } else {
      _controller.retakeImage();
      capturedImageNotifier.value = _controller.imagePath;
    }
    _progressAnimationController.animateTo(0.0);
  }

  /// Handle save action
  void _handleSave() {
    final data = documentDataNotifier.value;
    if (!widget.requireBothSides ||
        data.isCompleteFor(requireBothSides: widget.requireBothSides)) {
      widget.onBothSidesSaved(data);
      // Reset the controller after saving
      _controller.resetImage();
      capturedImageNotifier.value = _controller.imagePath;
    }
  }

  /// Handle retake current side
  void _handleRetake() {
    final currentSide = currentSideNotifier.value;
    final currentData = documentDataNotifier.value;

    if (currentSide == DocumentSide.front) {
      documentDataNotifier.value = currentData.copyWith(frontImagePath: "");
    } else {
      documentDataNotifier.value = currentData.copyWith(backImagePath: "");
    }

    // Use the controller's retake method
    _controller.retakeImage();
    capturedImageNotifier.value = _controller.imagePath;
    widget.onRetake?.call();
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: widget.progressIndicatorHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.white.withAlpha((0.3 * 255).toInt()),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.progressIndicatorColor ?? Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionText() {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: currentSideNotifier,
      builder: (context, currentSide, child) {
        final instruction = currentSide == DocumentSide.front
            ? (widget.frontSideInstruction ??
                  "Position the front side of your document within the frame")
            : (widget.backSideInstruction ??
                  "Now position the back side of your document within the frame");

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.6 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            instruction,
            style:
                widget.instructionTextStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildCurrentTitle() {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: currentSideNotifier,
      builder: (context, currentSide, child) {
        Widget? currentTitle;

        if (currentSide == DocumentSide.front &&
            widget.frontSideTitle != null) {
          currentTitle = widget.frontSideTitle;
        } else if (currentSide == DocumentSide.back &&
            widget.backSideTitle != null) {
          currentTitle = widget.backSideTitle;
        } else if (widget.title != null) {
          currentTitle = widget.title;
        }

        return currentTitle ?? const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate updated frame size clamped to screen size with margins
    final screenWidth = 1.sw(context);
    final screenHeight = 1.sh(context);

    final maxWidth = screenWidth;
    final maxHeight = .45 * screenHeight;

    final updatedFrameWidth = widget.frameWidth > maxWidth
        ? maxWidth
        : widget.frameWidth; // clamp to maxWidth

    final updatedFrameHeight = widget.frameHeight > maxHeight
        ? maxHeight
        : widget.frameHeight; // clamp to maxHeight

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
                frameWidth: updatedFrameWidth,
                frameHeight: updatedFrameHeight,
                borderRadius: widget.outerFrameBorderRadius,
              ),

            /// Frame capture animation when loading
            if (isInitialized)
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return FrameCaptureAnimation(
                      frameWidth: updatedFrameWidth,
                      frameHeight: updatedFrameHeight,
                      animationDuration: widget.capturingAnimationDuration,
                      animationColor: widget.capturingAnimationColor,
                      curve: widget.capturingAnimationCurve,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            ///  Draw the document frame
            TwoSidedAnimatedFrame(
              frameHeight: updatedFrameHeight,
              frameWidth: updatedFrameWidth,
              outerFrameBorderRadius: widget.outerFrameBorderRadius,
              innerCornerBroderRadius: widget.innerCornerBroderRadius,
              animatedFrameDuration: widget.animatedFrameDuration,
              flipAnimationDuration: widget.flipAnimationDuration,
              flipAnimationCurve: widget.flipAnimationCurve,
              animatedFrameCurve: widget.animatedFrameCurve,
              border: widget.frameBorder,
              currentSideNotifier: currentSideNotifier,
            ),

            /// Frame Bottom Container
            TwoSidedBottomFrameContainer(
              width: updatedFrameWidth,
              height: updatedFrameHeight,
              borderRadius: widget.outerFrameBorderRadius,
              currentSideNotifier: currentSideNotifier,
              documentDataNotifier: documentDataNotifier,
              bottomHintText: widget.bottomHintText,
              sideInfoOverlay: widget.sideInfoOverlay,
            ),

            /// Progress Indicator
            if (widget.requireBothSides && widget.showSideIndicator)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 0,
                right: 0,
                child: _buildProgressIndicator(),
              ),

            /// Instruction Text
            Positioned(
              top: widget.requireBothSides && widget.showSideIndicator
                  ? MediaQuery.of(context).padding.top + 120
                  : MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: _buildInstructionText(),
            ),

            /// Screen Title
            if (widget.title != null ||
                widget.frontSideTitle != null ||
                widget.backSideTitle != null ||
                widget.showCloseButton)
              ScreenTitle(
                title: _buildCurrentTitle(),
                showCloseButton: widget.showCloseButton,
                screenTitleAlignment: widget.screenTitleAlignment,
                screenTitlePadding: widget.screenTitlePadding,
              ),

            /// Side Indicator - Shows Front/Back progress
            if (widget.requireBothSides && widget.showSideIndicator)
              SideIndicator(
                currentSideNotifier: currentSideNotifier,
                documentDataNotifier: documentDataNotifier,
                rightPosition: 20,
                backgroundColor:
                    widget.sideIndicatorBackgroundColor ??
                    Colors.black.withAlpha((0.8 * 255).toInt()),
                borderColor: widget.sideIndicatorBorderColor,
                activeColor: widget.sideIndicatorActiveColor ?? Colors.blue,
                inactiveColor: widget.sideIndicatorInactiveColor ?? Colors.grey,
                completedColor:
                    widget.sideIndicatorCompletedColor ?? Colors.green,
                textStyle: widget.sideIndicatorTextStyle,
              ),

            /// Display action buttons with two-sided support
            TwoSidedActionButtons(
              // Camera control properties
              captureOuterCircleRadius: widget.captureOuterCircleRadius,
              captureInnerCircleRadius: widget.captureInnerCircleRadius,
              captureButtonAlignment: widget.captureButtonAlignment,
              captureButtonPadding: widget.captureButtonPadding,

              // Button text properties
              captureButtonText: widget.captureButtonText,
              captureFrontButtonText: widget.captureFrontButtonText,
              captureBackButtonText: widget.captureBackButtonText,
              saveButtonText: widget.saveButtonText,
              nextButtonText: widget.nextButtonText,
              previousButtonText: widget.previousButtonText,
              retakeButtonText: widget.retakeButtonText,

              // Button styling
              captureButtonTextStyle: widget.captureButtonTextStyle,
              actionButtonTextStyle: widget.actionButtonTextStyle,
              retakeButtonTextStyle: widget.retakeButtonTextStyle,
              captureButtonStyle: widget.captureButtonStyle,
              actionButtonStyle: widget.actionButtonStyle,
              retakeButtonStyle: widget.retakeButtonStyle,

              // Button dimensions and positioning
              actionButtonPadding: widget.actionButtonPadding,
              actionButtonWidth: widget.actionButtonWidth,
              actionButtonHeight: widget.actionButtonHeight,
              captureButtonWidth: widget.captureButtonWidth,
              captureButtonHeight: widget.captureButtonHeight,

              // State notifiers
              capturedImageNotifier: capturedImageNotifier,
              isLoadingNotifier: isLoadingNotifier,
              currentSideNotifier: currentSideNotifier,
              documentDataNotifier: documentDataNotifier,

              // Frame properties
              frameWidth: updatedFrameWidth,
              frameHeight: updatedFrameHeight,
              bottomFrameContainerHeight:
                  AppConstants.bottomFrameContainerHeight,

              // Controller
              controller: _controller,

              // Callbacks
              onCapture: _handleCapture,
              onSave: _handleSave,
              onRetake: _handleRetake,
              onNext: _switchToBackSide,
              onPrevious: _switchToFrontSide,
              onCameraSwitched: () async {
                isInitializedNotifier.value = false;
                await _controller.switchCamera();
                isInitializedNotifier.value = true;
              },

              // Configuration
              requireBothSides: widget.requireBothSides,
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
    currentSideNotifier.dispose();
    documentDataNotifier.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }
}
