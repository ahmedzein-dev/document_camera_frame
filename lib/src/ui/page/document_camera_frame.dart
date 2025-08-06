import 'dart:async';
import 'package:camera/camera.dart';
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../services/document_detection_service.dart';

/// A customizable camera view for capturing both sides of document images.
///
/// This widget provides a predefined frame for document capture,
/// with support for capturing front and back sides of documents.
class DocumentCameraFrame extends StatefulWidget {
  /// Width of the document capture frame.
  final double frameWidth;

  /// Height of the document capture frame.
  final double frameHeight;

  /// Animation styling configuration
  final DocumentCameraAnimationStyle animationStyle;

  /// Frame styling configuration
  final DocumentCameraFrameStyle frameStyle;

  /// Button styling configuration
  final DocumentCameraButtonStyle buttonStyle;

  /// Title styling configuration
  final DocumentCameraTitleStyle titleStyle;

  /// Side indicator styling configuration
  final DocumentCameraSideIndicatorStyle sideIndicatorStyle;

  /// Progress indicator styling configuration
  final DocumentCameraProgressStyle progressStyle;

  /// Instruction text styling configuration
  final DocumentCameraInstructionStyle instructionStyle;

  /// Callback triggered when front side is captured.
  final Function(String imgPath)? onFrontCaptured;

  /// Callback triggered when back side is captured.
  final Function(String imgPath)? onBackCaptured;

  /// Callback triggered when both sides are captured and saved.
  final Function(DocumentCaptureData documentData) onBothSidesSaved;

  /// Callback triggered when the "Retake" button is pressed.
  final VoidCallback? onRetake;

  /// Bottom container customization
  final Widget? bottomFrameContainerChild;

  /// Show close button
  final bool showCloseButton;

  /// Camera index
  final int? cameraIndex;

  /// Whether to require both sides (if false, can save with just front side)
  final bool requireBothSides;

  /// Optional bottom hint text shown in the bottom container.
  final String? bottomHintText;

  /// Optional widget shown on the right (e.g. a check icon).
  final Widget? sideInfoOverlay;

  /// Enables automatic capture when a document is aligned in the frame.
  final bool enableAutoCapture;

  /// Callback triggered when a camera-related error occurs (e.g., initialization, streaming, or capture failure).
  final void Function(Object error)? onCameraError;

  /// Constructor for the [DocumentCameraFrame].
  const DocumentCameraFrame({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.animationStyle = const DocumentCameraAnimationStyle(),
    this.frameStyle = const DocumentCameraFrameStyle(),
    this.buttonStyle = const DocumentCameraButtonStyle(),
    this.titleStyle = const DocumentCameraTitleStyle(),
    this.sideIndicatorStyle = const DocumentCameraSideIndicatorStyle(),
    this.progressStyle = const DocumentCameraProgressStyle(),
    this.instructionStyle = const DocumentCameraInstructionStyle(),
    this.onFrontCaptured,
    this.onBackCaptured,
    required this.onBothSidesSaved,
    this.onRetake,
    this.bottomFrameContainerChild,
    this.showCloseButton = false,
    this.cameraIndex,
    this.requireBothSides = true,
    this.bottomHintText,
    this.sideInfoOverlay,
    this.enableAutoCapture = false,
    this.onCameraError,
  });

  @override
  State<DocumentCameraFrame> createState() => _DocumentCameraFrameState();
}

class _DocumentCameraFrameState extends State<DocumentCameraFrame>
    with TickerProviderStateMixin {
  Timer? _debounceTimer;
  bool _isDebouncing = false;

  late DocumentCameraController _controller;

  // State notifiers
  final ValueNotifier<bool> _isInitializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String> _capturedImageNotifier = ValueNotifier("");
  final ValueNotifier<DocumentSide> _currentSideNotifier = ValueNotifier(
    DocumentSide.front,
  );
  final ValueNotifier<DocumentCaptureData> _documentDataNotifier =
      ValueNotifier(DocumentCaptureData());
  final ValueNotifier<bool> _isDocumentAlignedNotifier = ValueNotifier(false);

  // Animation controllers
  AnimationController? _progressAnimationController;
  Animation<double>? _progressAnimation;

  // Document detection
  DocumentDetectionService? _documentDetectionService;
  bool _isDetectorBusy = false;
  bool _isImageStreamActive = false;

  // Frame dimensions
  late double _updatedFrameWidth;
  late double _updatedFrameHeight;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedFrameDimensions) {
      _calculateFrameDimensions();
      _hasInitializedFrameDimensions = true;
    }
  }

  void _calculateFrameDimensions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final maxWidth = screenWidth;
    final maxHeight = 0.45 * screenHeight;

    _updatedFrameWidth = widget.frameWidth > maxWidth
        ? maxWidth
        : widget.frameWidth;
    _updatedFrameHeight = widget.frameHeight > maxHeight
        ? maxHeight
        : widget.frameHeight;
  }

  bool _hasInitializedFrameDimensions = false;

  Future<void> _initializeComponents() async {
    if (widget.sideIndicatorStyle.showSideIndicator) {
      _initializeProgressAnimation();
    }

    if (widget.enableAutoCapture) {
      _documentDetectionService = DocumentDetectionService(
        onError: widget.onCameraError,
      );
      _documentDetectionService!.initialize();
    }

    await _initializeCamera();
  }

  void _initializeProgressAnimation() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Initializes the camera and updates the state when ready.
  Future<void> _initializeCamera() async {
    try {
      _controller = DocumentCameraController();
      await _controller.initialize(
        widget.cameraIndex ?? 0,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      if (!mounted) return;

      _isInitializedNotifier.value = true;

      if (widget.enableAutoCapture) {
        await _startImageStream();
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      widget.onCameraError?.call(e);
    }
  }

  // Safe image stream management methods
  Future<void> _startImageStream() async {
    if (_isImageStreamActive ||
        _controller.cameraController == null ||
        !_controller.cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _controller.cameraController!.startImageStream(_processCameraImage);
      _isImageStreamActive = true;
    } catch (e) {
      debugPrint('Failed to start image stream: $e');
      _isImageStreamActive = false;
      widget.onCameraError?.call(e);
    }
  }

  Future<void> _stopImageStream() async {
    final controller = _controller.cameraController;
    if (!_isImageStreamActive ||
        controller == null ||
        !controller.value.isStreamingImages) {
      return;
    }

    try {
      await controller.stopImageStream();
    } catch (e) {
      debugPrint('Failed to stop image stream: $e');
      widget.onCameraError?.call(e);
    } finally {
      _isImageStreamActive = false;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetectorBusy || !mounted || _documentDetectionService == null) {
      return;
    }

    if (_capturedImageNotifier.value.isNotEmpty) {
      if (_isDocumentAlignedNotifier.value) {
        _isDocumentAlignedNotifier.value = false;
      }
      return;
    }

    _isDetectorBusy = true;

    try {
      final bool isAligned = await _documentDetectionService!.processImage(
        image: image,
        cameraController: _controller.cameraController!,
        context: context,
        frameWidth: _updatedFrameWidth,
        frameHeight: _updatedFrameHeight,
        screenWidth: MediaQuery.of(context).size.width.toInt(),
        screenHeight: MediaQuery.of(context).size.height.toInt(),
      );

      if (!mounted) return;

      _isDocumentAlignedNotifier.value = isAligned;

      if (isAligned) {
        if (!_isDebouncing) {
          _isDebouncing = true;

          _debounceTimer = Timer(const Duration(seconds: 1), () async {
            if (_isDocumentAlignedNotifier.value && mounted) {
              await _captureAndHandleImageUnified(
                context,
                _updatedFrameWidth,
                _updatedFrameHeight + AppConstants.bottomFrameContainerHeight,
                1.sw(context).toInt(),
                1.sh(context).toInt(),
              );
            }
            _isDebouncing = false;
            _debounceTimer = null;
          });
        }
      } else {
        if (_isDebouncing) {
          _debounceTimer?.cancel();
          _debounceTimer = null;
          _isDebouncing = false;
        }
      }
    } catch (e) {
      debugPrint('Image processing error: $e');
      widget.onCameraError?.call(e);
    } finally {
      _isDetectorBusy = false;
    }
  }

  Future<void> _captureAndHandleImageUnified(
    BuildContext context,
    double frameWidth,
    double frameHeight,
    int screenWidth,
    int screenHeight,
  ) async {
    if (_isLoadingNotifier.value) {
      return; // Prevent multiple simultaneous captures
    }

    _isLoadingNotifier.value = true;

    try {
      // Stop image stream before capture to prevent conflicts
      if (widget.enableAutoCapture && _isImageStreamActive) {
        await _stopImageStream();
      }

      await _controller.takeAndCropPicture(
        frameWidth,
        frameHeight,
        screenWidth,
        screenHeight,
      );

      _capturedImageNotifier.value = _controller.imagePath;
      _handleCapture(_controller.imagePath);
    } catch (e) {
      debugPrint('Capture failed: $e');
      widget.onCameraError?.call(e);
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  /// Handle image capture based on current side
  void _handleCapture(String imagePath) {
    final currentSide = _currentSideNotifier.value;
    final currentData = _documentDataNotifier.value;

    if (currentSide == DocumentSide.front) {
      _documentDataNotifier.value = currentData.copyWith(
        frontImagePath: imagePath,
      );
      widget.onFrontCaptured?.call(imagePath);
    } else {
      _documentDataNotifier.value = currentData.copyWith(
        backImagePath: imagePath,
      );
      widget.onBackCaptured?.call(imagePath);
    }
  }

  /// Switch to back side capture
  void _switchToBackSide() {
    _currentSideNotifier.value = DocumentSide.back;
    _controller.resetImage();
    _capturedImageNotifier.value = _controller.imagePath;

    _progressAnimationController?.animateTo(1.0);

    // Restart stream for auto-capture
    if (widget.enableAutoCapture) {
      _restartImageStreamSafely();
    }
  }

  /// Switch to front side capture
  void _switchToFrontSide() {
    _currentSideNotifier.value = DocumentSide.front;
    final frontImagePath = _documentDataNotifier.value.frontImagePath;

    if (frontImagePath != null && frontImagePath.isNotEmpty) {
      _capturedImageNotifier.value = frontImagePath;
    } else {
      _controller.resetImage();
      _capturedImageNotifier.value = _controller.imagePath;
    }

    _progressAnimationController?.animateTo(0.0);

    // Restart stream for auto-capture if no front image exists
    if (widget.enableAutoCapture &&
        (frontImagePath == null || frontImagePath.isEmpty)) {
      _restartImageStreamSafely();
    }
  }

  /// Handle save action
  void _handleSave() {
    final data = _documentDataNotifier.value;
    if (!widget.requireBothSides ||
        data.isCompleteFor(requireBothSides: widget.requireBothSides)) {
      widget.onBothSidesSaved(data);
      _resetCapture();
    }
  }

  /// Handle retake current side
  void _handleRetake() {
    final currentSide = _currentSideNotifier.value;
    final currentData = _documentDataNotifier.value;

    if (currentSide == DocumentSide.front) {
      _documentDataNotifier.value = currentData.copyWith(frontImagePath: "");
    } else {
      _documentDataNotifier.value = currentData.copyWith(backImagePath: "");
    }

    _controller.retakeImage();
    _capturedImageNotifier.value = _controller.imagePath;

    // Restart image stream for auto-capture if enabled
    if (widget.enableAutoCapture) {
      _restartImageStreamSafely();
    }

    widget.onRetake?.call();
  }

  // Helper method to safely restart image stream
  Future<void> _restartImageStreamSafely() async {
    try {
      // Ensure stream is stopped first
      if (_isImageStreamActive) {
        await _stopImageStream();
      }

      // Small delay to ensure camera is ready
      await Future.delayed(widget.animationStyle.frameFlipDuration);

      // Start the stream again
      await _startImageStream();
    } catch (e) {
      debugPrint('Failed to restart image stream: $e');
      widget.onCameraError?.call(e);
    }
  }

  void _resetCapture() {
    _controller.resetImage();
    _capturedImageNotifier.value = _controller.imagePath;
    // _currentSideNotifier.value = DocumentSide.front;
    // _documentDataNotifier.value = DocumentCaptureData();
    // _progressAnimationController?.reset();
  }

  Widget _buildProgressIndicator() {
    if (_progressAnimation == null) return const SizedBox.shrink();

    return Container(
      height: widget.progressStyle.progressIndicatorHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _progressAnimation!,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressAnimation!.value,
            backgroundColor: Colors.white.withAlpha((0.3 * 255).toInt()),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.progressStyle.progressIndicatorColor ??
                  Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionText() {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: _currentSideNotifier,
      builder: (context, currentSide, child) {
        final instruction = currentSide == DocumentSide.front
            ? (widget.instructionStyle.frontSideInstruction ??
                  "Position the front side of your document within the frame")
            : (widget.instructionStyle.backSideInstruction ??
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
                widget.instructionStyle.instructionTextStyle ??
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
      valueListenable: _currentSideNotifier,
      builder: (context, currentSide, child) {
        Widget? currentTitle;

        if (currentSide == DocumentSide.front &&
            widget.titleStyle.frontSideTitle != null) {
          currentTitle = widget.titleStyle.frontSideTitle;
        } else if (currentSide == DocumentSide.back &&
            widget.titleStyle.backSideTitle != null) {
          currentTitle = widget.titleStyle.backSideTitle;
        } else if (widget.titleStyle.title != null) {
          currentTitle = widget.titleStyle.title;
        }

        return currentTitle ?? const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<bool>(
        valueListenable: _isInitializedNotifier,
        builder: (context, isInitialized, child) => Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (isInitialized && _controller.cameraController != null)
              CameraPreview(_controller.cameraController!),

            // Captured image preview
            if (isInitialized)
              CapturedImagePreview(
                capturedImageNotifier: _capturedImageNotifier,
                frameWidth: _updatedFrameWidth,
                frameHeight: _updatedFrameHeight,
                borderRadius: widget.frameStyle.outerFrameBorderRadius,
              ),

            // Frame capture animation
            if (isInitialized)
              ValueListenableBuilder<bool>(
                valueListenable: _isLoadingNotifier,
                child: FrameCaptureAnimation(
                  frameWidth: _updatedFrameWidth,
                  frameHeight: _updatedFrameHeight,
                  animationDuration:
                      widget.animationStyle.capturingAnimationDuration,
                  animationColor: widget.animationStyle.capturingAnimationColor,
                  curve: widget.animationStyle.capturingAnimationCurve,
                ),
                builder: (context, isLoading, child) {
                  return isLoading ? child! : const SizedBox.shrink();
                },
              ),

            // Document frame
            ValueListenableBuilder<bool>(
              valueListenable: _isDocumentAlignedNotifier,
              builder: (context, isAligned, child) {
                return TwoSidedAnimatedFrame(
                  frameHeight: _updatedFrameHeight,
                  frameWidth: _updatedFrameWidth,
                  outerFrameBorderRadius:
                      widget.frameStyle.outerFrameBorderRadius,
                  innerCornerBroderRadius:
                      widget.frameStyle.innerCornerBroderRadius,
                  frameFlipDuration: widget.animationStyle.frameFlipDuration,
                  frameFlipCurve: widget.animationStyle.frameFlipCurve,
                  border: widget.frameStyle.frameBorder,
                  currentSideNotifier: _currentSideNotifier,
                  isDocumentAligned: isAligned,
                );
              },
            ),

            // Bottom frame container
            TwoSidedBottomFrameContainer(
              width: _updatedFrameWidth,
              height: _updatedFrameHeight,
              borderRadius: widget.frameStyle.outerFrameBorderRadius,
              currentSideNotifier: _currentSideNotifier,
              documentDataNotifier: _documentDataNotifier,
              bottomHintText: widget.bottomHintText,
              sideInfoOverlay: widget.sideInfoOverlay,
            ),

            // Progress indicator
            if (widget.requireBothSides &&
                widget.sideIndicatorStyle.showSideIndicator)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 0,
                right: 0,
                child: _buildProgressIndicator(),
              ),

            // Instruction text
            Positioned(
              top:
                  widget.requireBothSides &&
                      widget.sideIndicatorStyle.showSideIndicator
                  ? MediaQuery.of(context).padding.top + 120
                  : MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: _buildInstructionText(),
            ),

            // Screen title
            if (widget.titleStyle.title != null ||
                widget.titleStyle.frontSideTitle != null ||
                widget.titleStyle.backSideTitle != null ||
                widget.showCloseButton)
              ScreenTitle(
                title: _buildCurrentTitle(),
                showCloseButton: widget.showCloseButton,
                screenTitleAlignment: widget.titleStyle.screenTitleAlignment,
                screenTitlePadding: widget.titleStyle.screenTitlePadding,
              ),

            // Side indicator
            if (widget.requireBothSides &&
                widget.sideIndicatorStyle.showSideIndicator)
              SideIndicator(
                currentSideNotifier: _currentSideNotifier,
                documentDataNotifier: _documentDataNotifier,
                rightPosition: 20,
                backgroundColor:
                    widget.sideIndicatorStyle.sideIndicatorBackgroundColor ??
                    Colors.black.withAlpha((0.8 * 255).toInt()),
                borderColor: widget.sideIndicatorStyle.sideIndicatorBorderColor,
                activeColor:
                    widget.sideIndicatorStyle.sideIndicatorActiveColor ??
                    Colors.blue,
                inactiveColor:
                    widget.sideIndicatorStyle.sideIndicatorInactiveColor ??
                    Colors.grey,
                completedColor:
                    widget.sideIndicatorStyle.sideIndicatorCompletedColor ??
                    Colors.green,
                textStyle: widget.sideIndicatorStyle.sideIndicatorTextStyle,
              ),

            // Action buttons
            TwoSidedActionButtons(
              captureOuterCircleRadius:
                  widget.buttonStyle.captureOuterCircleRadius,
              captureInnerCircleRadius:
                  widget.buttonStyle.captureInnerCircleRadius,
              captureButtonAlignment: widget.buttonStyle.captureButtonAlignment,
              captureButtonPadding: widget.buttonStyle.captureButtonPadding,
              captureButtonText: widget.buttonStyle.captureButtonText,
              captureFrontButtonText: widget.buttonStyle.captureFrontButtonText,
              captureBackButtonText: widget.buttonStyle.captureBackButtonText,
              saveButtonText: widget.buttonStyle.saveButtonText,
              nextButtonText: widget.buttonStyle.nextButtonText,
              previousButtonText: widget.buttonStyle.previousButtonText,
              retakeButtonText: widget.buttonStyle.retakeButtonText,
              captureButtonTextStyle: widget.buttonStyle.captureButtonTextStyle,
              actionButtonTextStyle: widget.buttonStyle.actionButtonTextStyle,
              retakeButtonTextStyle: widget.buttonStyle.retakeButtonTextStyle,
              captureButtonStyle: widget.buttonStyle.captureButtonStyle,
              actionButtonStyle: widget.buttonStyle.actionButtonStyle,
              retakeButtonStyle: widget.buttonStyle.retakeButtonStyle,
              actionButtonPadding: widget.buttonStyle.actionButtonPadding,
              actionButtonWidth: widget.buttonStyle.actionButtonWidth,
              actionButtonHeight: widget.buttonStyle.actionButtonHeight,
              captureButtonWidth: widget.buttonStyle.captureButtonWidth,
              captureButtonHeight: widget.buttonStyle.captureButtonHeight,
              capturedImageNotifier: _capturedImageNotifier,
              isLoadingNotifier: _isLoadingNotifier,
              currentSideNotifier: _currentSideNotifier,
              documentDataNotifier: _documentDataNotifier,
              frameWidth: _updatedFrameWidth,
              frameHeight: _updatedFrameHeight,
              bottomFrameContainerHeight:
                  AppConstants.bottomFrameContainerHeight,
              controller: _controller,
              onManualCapture: _captureAndHandleImageUnified,
              onSave: _handleSave,
              onRetake: _handleRetake,
              onNext: _switchToBackSide,
              onPrevious: _switchToFrontSide,
              onCameraSwitched: () async {
                _isInitializedNotifier.value = false;
                if (widget.enableAutoCapture) {
                  await _stopImageStream();
                }

                await _controller.switchCamera();
                _isInitializedNotifier.value = true;

                if (widget.enableAutoCapture) {
                  await _startImageStream();
                }
              },
              requireBothSides: widget.requireBothSides,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Start async disposal but don't await it here
    _disposeAsync();

    // Dispose sync stuff
    _controller.dispose();
    _documentDetectionService?.dispose();
    _progressAnimationController?.dispose();

    _isInitializedNotifier.dispose();
    _isLoadingNotifier.dispose();
    _capturedImageNotifier.dispose();
    _currentSideNotifier.dispose();
    _documentDataNotifier.dispose();
    _isDocumentAlignedNotifier.dispose();

    _debounceTimer?.cancel();
    _debounceTimer = null;

    super.dispose();
  }

  Future<void> _disposeAsync() async {
    if (widget.enableAutoCapture) {
      await _stopImageStream();
    }
  }
}
