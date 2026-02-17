import 'package:flutter/material.dart';

import '../../../document_camera_frame.dart';
import '../../logic/document_camera_logic.dart';
import '../widgets/document_camera_preview_layer.dart';
import '../widgets/document_camera_overlay_layer.dart';

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

  /// Callback triggered when document capture is saved (one side e.g. passport, or both sides).
  final Function(DocumentCaptureData documentData)? onDocumentSaved;

  /// Deprecated. Use [onDocumentSaved] instead.
  @Deprecated(
    'Use onDocumentSaved instead (works for one-sided and two-sided documents)',
  )
  final Function(DocumentCaptureData documentData)? onBothSidesSaved;

  /// When true, runs on-device OCR and includes [DocumentCaptureData.frontOcrText] and
  /// [DocumentCaptureData.backOcrText] in the callback result.
  final bool enableExtractText;

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

  /// Show the (dynamic) live detection status text (e.g. "Move closer").
  ///
  /// Has effect only when auto-capture is enabled and detection is running.
  final bool showDetectionStatusText;

  /// Callback triggered when a camera-related error occurs (e.g., initialization, streaming, or capture failure).
  final void Function(Object error)? onCameraError;

  /// Output format for captured documents (default: JPG for backward compatibility)
  final DocumentOutputFormat outputFormat;

  /// PDF page size when outputFormat is PDF (default: A4)
  final PdfPageSize pdfPageSize;

  /// Image quality for lossy formats like JPG and WebP (1-100, default: 90)
  final int imageQuality;

  /// Initial flash mode for the camera (default: FlightMode.auto)
  final FlashMode initialFlashMode;

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
    this.onDocumentSaved,
    this.onBothSidesSaved,
    this.enableExtractText = false,
    this.onRetake,
    this.bottomFrameContainerChild,
    this.showCloseButton = false,
    this.cameraIndex,
    this.requireBothSides = true,
    this.bottomHintText,
    this.sideInfoOverlay,
    this.enableAutoCapture = false,
    this.showDetectionStatusText = true,
    this.onCameraError,
    this.outputFormat = DocumentOutputFormat.jpg,
    this.pdfPageSize = PdfPageSize.a4,
    this.imageQuality = 90,
    this.initialFlashMode = FlashMode.auto,
  }) : assert(
         onDocumentSaved != null || onBothSidesSaved != null,
         'Either onDocumentSaved or onBothSidesSaved must be provided',
       );

  @override
  State<DocumentCameraFrame> createState() => _DocumentCameraFrameState();
}

class _DocumentCameraFrameState extends State<DocumentCameraFrame>
    with TickerProviderStateMixin {
  late final DocumentCameraLogic _logic;

  // Animation controllers
  AnimationController? _progressAnimationController;
  Animation<double>? _progressAnimation;

  @override
  void initState() {
    super.initState();
    _logic = DocumentCameraLogic(
      context: context,
      onCameraError: () => widget.onCameraError?.call('Camera error'),
      onFrontCaptured: widget.onFrontCaptured,
      onBackCaptured: widget.onBackCaptured,
      onDocumentSaved: (data) =>
          (widget.onDocumentSaved ?? widget.onBothSidesSaved)?.call(data),
      enableExtractText: widget.enableExtractText,
      onRetake: widget.onRetake,
      enableAutoCapture: widget.enableAutoCapture,
      requireBothSides: widget.requireBothSides,
      frameFlipDuration: widget.animationStyle.frameFlipDuration,
      outputFormat: widget.outputFormat,
      pdfPageSize: widget.pdfPageSize,
      imageQuality: widget.imageQuality,
      initialFlashMode: widget.initialFlashMode,
    );

    if (widget.sideIndicatorStyle.showSideIndicator) {
      _initializeProgressAnimation();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logic.initialize(
        frameWidth: widget.frameWidth,
        frameHeight: widget.frameHeight,
        cameraIndex: widget.cameraIndex,
      );
    });
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

    // Sync animation with logic
    _logic.currentSideNotifier.addListener(() {
      if (_logic.currentSideNotifier.value == DocumentSide.back) {
        _progressAnimationController?.animateTo(1.0);
      } else {
        _progressAnimationController?.animateTo(0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Preview Layer
          DocumentCameraPreviewLayer(
            logic: _logic,
            borderRadius: widget.frameStyle.outerFrameBorderRadius,
            capturingAnimationDuration:
                widget.animationStyle.capturingAnimationDuration,
            capturingAnimationColor:
                widget.animationStyle.capturingAnimationColor,
            capturingAnimationCurve:
                widget.animationStyle.capturingAnimationCurve,
          ),

          // Overlay Layer
          ValueListenableBuilder<bool>(
            valueListenable: _logic.isInitializedNotifier,
            builder: (context, isInitialized, child) {
              if (!isInitialized) return const SizedBox.shrink();
              return DocumentCameraOverlayLayer(
                logic: _logic,
                frameStyle: widget.frameStyle,
                animationStyle: widget.animationStyle,
                bottomHintText: widget.bottomHintText,
                sideInfoOverlay: widget.sideInfoOverlay,
                sideIndicatorStyle: widget.sideIndicatorStyle,
                progressStyle: widget.progressStyle,
                progressAnimation: _progressAnimation,
                showDetectionStatusText: widget.showDetectionStatusText,
                instructionStyle: widget.instructionStyle,
                titleStyle: widget.titleStyle,
                showCloseButton: widget.showCloseButton,
                buttonStyle: widget.buttonStyle,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logic.dispose();
    _progressAnimationController?.dispose();
    super.dispose();
  }
}
